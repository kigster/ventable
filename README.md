[![Build status](https://secure.travis-ci.org/kigster/ventable.png)](http://travis-ci.org/kigster/ventable)

# Ventable

Simple eventing gem that implements Observable pattern, but with more options, ability to group observers and wrap
them in arbitrary blocks of code.  For example, when a certain event fires, some observers may be called within
a transaction context, while others maybe called outside of the transaction context.

## Installation

Add this line to your application's Gemfile:

    gem 'ventable'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ventable

## Usage

1. Create your own plain ruby class that optionally carries some data important to the event. Include module Ventable::Event.
2. Create one or more observers.  Observer can be any class that implements event handler method as a class method, such as a
   generic method ```self.handle_event(event)``` or a more specific method mapped to the event name: say for event UserRegistered the
   callback event would be ```self.handle_user_registered_event(event)```
3. If you have not used observe method, add your observer by calling "observed_by" class method on the event, and add the observer.
4. Instantiate your event, and call fire!() method.

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
  def self.handle_wake_up_event(event)
    self.wake_up
    puts "snoozing at #{event.wakeup_time}"
    self.snooze(5)
  end
  #.. implementation
end

# Register the observer
AlarmSoundEvent.notifies SleepingPerson

# Create and fire the event
AlarmSoundEvent.new(Date.new).fire!
```

## Using #configure and groups


Events can be configured to call observers in groups, with an optional block around it.

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

  # this group will be notified next
  group :transaction, &transaction

  # this block is executed after the group
  notifies inside: :transaction do
    # perform block
  end

  # these observers are run inside the transaction block
  notifies ObserverClass1, ObserverClass2, inside: :transaction

  # this one is the last to be notified
  notifies AnotherObserverClass
end

SomeEvent.new.fire!

```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Author

Konstantin Gredeskoul, @kig, http://github.com/kigster
