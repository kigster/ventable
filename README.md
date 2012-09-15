# Ventable

Simple eventing gem that implements Observable pattern.

## Installation

Add this line to your application's Gemfile:

    gem 'ventable'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ventable

## Usage

1. Create your own event class that optionally carries some data important to the event. Include module Ventable::Event.
2. Create one or more observers.  Observer can be any class that implements event handler, or you can include Ventable::Observer to get "observe" class method.
3. If you have not used observe method, add your observer by calling "observed_by" class method on the event, and add the observer.
4. Instantiate your event, and call fire!() method.

## Example

```ruby
require 'ventable'

# this is a custom Event class that has some data
class WakeUpEvent
  include Ventable::Event
  attr_accessor :wakeup_time, :user

  def initialize(user, wakeup_time)
    self.user = user
    self.wakeup_time = wakeup_time
  end
end

# Mom is an observer, interested in WakeUpEvents
class Mom
  include Ventable::Observer
  observe WakeUpEvent, :wake_mom_up

  def make_breakfast
    puts "MOM: Breakfast is coming!"
  end

  def self.wake_mom_up(event)
    self.find_mom_for(event.user).make_breakfast
  end

  def self.find_mom_for(user)
    Mom.new
  end
end

# Boss is also an observer
class Boss
  def discipline_employee(user)
    puts "BOSS: Mr #{user.last}, you need to get before 9am!"
  end

  def handle_wake_up_event(event)
    if event.wakeup_time.hour < 9
      discipline_employee(event.user)
    end
  end
end

WakeUpEvent.observed_by Boss.new

begin
  user = Struct.new(:first,:last).new("John", "Doe")
  event = WakeUpEvent.new(user, Time.now)
  event.fire!
end


```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
