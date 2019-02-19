require 'set'

module ::Ventable
  module Event

    module InstanceMethods
      def publish
        return unless Ventable.enabled?
        Event.queue << self
      rescue StandardError => e
        raise Errors::EventPublishingError.new(self, e)
      end

      alias fire publish

      def publish_synchronously(&block)
        return unless Ventable.enabled?
        observers.each do |observer|
          notify_observer(observer, self, &block)
        end
      end

      def observers
        self.class.observers
      end

      def my_event_name
        self.class.event_name
      end

      def my_event_symbol
        self.class.event_symbol
      end

      private

      def notify_observer(observer, event, &block)
        case observer
        when Proc
          observer.call(event, &block)
        else
          method = self.class.callback_for(observer)
          observer.send(method, event, &block)
        end
      rescue StandardError => e
        raise Errors::EventPublishingError.new(self, observer, e)
      end
    end
  end
end
