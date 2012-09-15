require 'ventable'

describe Ventable do

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

  it "notifies both observers when event fires" do
    event = SomeEvent.create_event do
      ["John", [1,2,3]]
    end
    event.should be_kind_of(SomeEvent)

    AnotherObserver.should_receive(:some_event_handler).with(event).once
    SomeObserver.should_receive(:some_event_handler).with(event).once
    event.fire!
  end

end
