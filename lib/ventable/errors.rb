require 'colored2'
module Ventable
  module Errors
    class VentableError < StandardError; end

    class DuplicateEventName < VentableError
      def initialize(event_name, existing_event, new_event)
        super("Event name #{event_name.to_s.bold.magenta} is already registered with #{existing_event.to_s.bold.yellow}, please choose another name for #{new_event.to_s.red.underlined}")
      end
    end

    class EventPublishingError < VentableError
      def initialize(event, exception)
        super("Error while publishing event #{event}: #{exception.inspect.bold.red}")
      end
    end

    class EventPublishingObserverError < VentableError
      def initialize(event, observer, exception)
        super("Error while notifying observer #{observer} of event #{event}, #{exception.inspect.bold.red}")
      end
    end
  end
end

