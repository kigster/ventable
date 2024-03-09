![Gem Version](https://badge.fury.io/rb/ventable.svg)
[![Gitter](https://img.shields.io/gitter/room/gitterHQ/gitter.svg)](https://gitter.im/kigster/ventable)
![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fkigster%2Fventable.svg?type=shield)

[![RSpec](https://github.com/kigster/ventable/actions/workflows/ruby.yml/badge.svg)](https://github.com/kigster/ventable/actions/workflows/ruby.yml)
[![Rubocop](https://github.com/kigster/ventable/actions/workflows/rubocop.yml/badge.svg)](https://github.com/kigster/ventable/actions/workflows/rubocop.yml)

# Ventable

This gem is a variation of the [Observer Design Pattern](https://en.wikipedia.org/wiki/Observer_pattern). 

In particular: 

 * Ventable requires creation of simple event classes that may carry data and be serialized.
 * Observers can be grouped together, and notified within a pre-defined `Proc`. For example, using grouping some observers may be called within the boundaries of a database transaction, while others maybe called outside of it.
 * Ventable allows both compile time and run time observer binding.
 * Ventable calls specific method on each observer, using automatically derived method name from the event class. A generic `#handle_event` method is also supported.

Limitations:

 * At the moment, Ventable can only notify observers within the current ruby process.
 
## Plugins

Ventable has several plugins that add various functionality on top of the basic event dispatch mechanism.

 * [ventable-statsd](https://github.com/kigster/ventable-statsd) is an extension that allows notifying Statsd whenever an event occurs.
 * [simple-feed](https://github.com/kigster/simple-feed) is a generic implementation of the activity feed concept commonly seen on social networks,  and it integrates nicely with Ventable.

## Ruby Versions

This gem has been verified to work in the following ruby versions:

 * MRI Ruby
   * 1.9.3-p551
   * 2.2
   * 2.3
   * 2.4

The gem also likely works with non-MRI rubies, but it has not been tested.
    
## Installation

Add this line to your application's Gemfile:

    gem 'ventable'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ventable

## Usage

1. Create your own plain ruby Event class that optionally carries some data important to the event. Include module `Ventable::Event`.

2. Create one or more observers.  Observer can be any class that implements event handler method as a class method, such as a
   generic method `self.handle(event)` or a more specific method mapped to the event name: say for event UserRegistered the
   callback event would be `self.handle_user_registered(event)`

3. Register your observers with the event using `notifies` event method, or register groups using `group` method, and then
   use `notify` with options `inside: :group_name`

4. Instantiate your event class (optionally with some data), and call `publish` or, a deprecated `fire!` method.

## Example

```ruby
require 'ventable'

# this is a custom Event class that has some data associated with it

class AlarmSoundEvent
  include Ventable::Event
  attr_accessor :wakeup_time

  def initialize(wakeup_time)
    @wakeup_time = wakeup_time
  end
end

# This class is an observer, interested in WakeUpEvents.
class SleepingPerson
  def self.handle_alarm_sound event
    self.wake_up
    puts "snoozing at #{event.wakeup_time}"
    self.snooze(5)
  end
end

# Register the observer
AlarmSoundEvent.notifies SleepingPerson

# Create and fire the event
AlarmSoundEvent.new(Date.new).publish
```

## Using #configure and groups

Events can be configured to call observers in groups, with an optional block around it.  Using groups
allows you (as in this example) wrap some observers in a transaction, and control the order of notification.

```ruby
transaction = ->(b){
  ActiveRecord::Base.transaction do
    b.call
  end
}

class SomeEvent
  include Ventable::Event
end

SomeEvent.configure do
  # first observer to be called
  notifies FirstObserverClassToBeCalled

  # any observers in this group will be notified next...
  group :transaction, &transaction

  # this block will be run as the first member of the group
  notifies inside: :transaction do
    # perform block
  end

  # this observer gets notified after all observers inside :transactions are notified
  notifies AnotherObserverClass

  # these two observers are called at the end of the transaction group,
  # but before AnotherObserverClass is notified.
  notifies ObserverClass1, ObserverClass2, inside: :transaction
end

SomeEvent.new.publish
```

## Callback Method Name

When the observer is notified, Ventable library will call a class method on your observer, with the name determined
using the following logic:

1. If your event defines ```EventClass.ventable_callback_method_name``` method, it's return value is used as a method name.
2. If not, your event's fully qualified class name is converted to a method name with underscrores. This method name
   always begings with ```handle_```.  For example, a class ```User::RegistrationEvent``` will generate callback
   method name ```ObserverClass.handle_user__registration(event)``` (note that '::' is converted to two underscores).
3. If neither method is found in the observer, a generic ```ObserverClass.handle(event)``` method is called.

## Guidelines for Using Ventable with Rails

You should start by defining your event library for your application (list of events
that are important to you),  you can place these files anywhere you like, such as
`lib/events` or `app/events`, etc.

It is recommended to `configure` all events and their observers in the `event_initializer.rb` file,
inside the `config/ininitalizers` folder.  You may need to require your events in that file also.

When your event is tied to a creation of a "first class objects", such as user registration,
it is recommended to create the User record first, commit it to the database, and then throw
a `UserRegisteredEvent.new(user).publish`, and have all subsequent logic broeken into
their respective classes.  For example, if you need to send an email to the user, have a `Mailer`
class observe the `UserRegisteredEvent`, and so all the mailing logic can live inside the `Mailer`
class, instead of, say, registration controller directly calling `Mailer.deliver_user_registration!(user)`.
The callback method will receive the event, that wraps the User instance, or any other useful data necessary.

## Integration with tests

There are times when it may be desirable to disable all eventing. For instance, when writing unit tests,
testing that events are published may be useful, but integrating with all observers adds complexity and confusion.
In these cases, Ventable may be globally disabled.

```ruby
## in spec_helper

around :each, eventing: false do |example|
  Ventable.disable
  example.run
  Ventable.enable
end
```

Now in a spec file:

```ruby
describe "Stuff", eventing: false do
  it 'does stuff' do
    ... my code that publishes events, in isolation from event observers
  end

  it 'tests that events are published, using stubs' do
    event = double(publish: true)
    allow(MyEvent).to receive(:new).and_return(event)
    ... my code that should fire event
    expect(event).to have_received(:publish)
  end
end

describe 'Other stuff' do
  it 'actually calls through to all observers, so valid data is required' do
  end
end
```

Note that in the version of RSpec that Ventable has been tested with, tags on a `describe` block
override tags on an `it` block.

## Further Discussion

It is worth mentioning that in the current form this gem is simply a software design pattern.  It helps
decouple code that performs tasks related to the same event (such as user registration, or comment posting),
but unrelated to each other (such as sending email to the user).

Future versions of this gem may offer a way to further decouple observers, by allowing them to be notified
via a background queue, such as Sidekiq or Resque. If you are interested in helping, please email the author.

For more information, check out the following blog post:

[Detangling Business Logic in Rails Apps with Pure Ruby Observers](http://building.wanelo.com/2013/08/05/detangling-business-logic-in-rails-apps-with-poro-events-and-observers.html).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Author

Konstantin Gredeskoul, @kig, http://github.com/kigster


## License
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fkigster%2Fventable.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2Fkigster%2Fventable?ref=badge_large)
