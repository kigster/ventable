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

```ruby
  require 'ventable'

  class SomeEvent
    include Ventable::Event
    attr_accessor :data
    def initialize(data)
      @data = data
    end
  end

  class SomeObserver
    include Ventable::Observer
    observe SomeEvent, :some_event_handler

    def self.some_event_handler(event)
      puts "SomeObserver got event #{event}"
    end
  end

  class AnotherObserver
    def self.some_event_handler(event)
      puts "AnotherObserver got event #{event}"
    end
  end

  SomeEvent.observe_by AnotherObserver, :some_event_handler

  ....

  SomeEvent.create{ User.create!(:username => "test") }.fire!

  # should generate the following output:

  SomeObserver got event #<SomeEvent:0x007fbd7b8c6f00>
  AnotherObserver got event #<SomeEvent:0x007fbd7b8c6f00>
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
