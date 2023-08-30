require 'set'

module Ventable
  module Event
    module ClassMethods
      def configure(&block)
        class_eval(&block)
      end

      def notifies(*observer_list, inside: nil, **opts, &block)
        observer_set = if inside
                         find_observer_group(groups)&.observers
                       else
                         observers
                       end

        raise Ventable::Error.new("found nil observer in params #{observer_list.inspect}") if observer_list.any?(&:nil?)
        observer_list.compact.each { |o| observer_set << o } unless observer_list.empty?
        observer_set << block if block
      end

      def group(name, &block)
        self.observers << Observer.new(name, Set.new, block)
      end

      def event_name(name = nil)
        if name
          new_name = name.to_sym
          if @event_name && @event_name != new_name
            Event.event_hash.delete(@event_name)
            @event_name = new_name
          end
          Event.event_hash[@event_name] = self
        else
          @event_name ||= ('publish_' + short_class_name + '_event').to_sym
        end

        @event_name
      end

      protected

      def find_observer_group(name)
        observers.find { |o| o.name == name }.tap do |result|
          raise Ventable::Errors::MissingGroupError.new(name) if result.nil?
        end
      end

      def short_class_name
        @short_class_name ||= (respond_to?(:name) ? name : self.class.name).gsub(/::/, '.').underscore.gsub(/_event$/, '')
      end

      private

      # Determine method name to call when notifying observers from this event.
      def default_callback_methods
        if respond_to?(:ventable_event_name)
          Array(ventable_event_name)
        else
          ['handle_' + self.short_class_name,
           short_class_name,
           short_class_name + '_event',
           'handle_event'].map(&:to_sym)
        end
      end
    end
  end
end
