module Ventable
  module Errors
    class EventError < StandardError
      attr_accessor :event
      def initialize(*args, event: nil)
        super(*args)
        self.event = event
      end
    end

    class FireError < EventError
      def initialize(event)
        super("#{event.event_name} fire error", event: event)
      end
    end
  end
end

