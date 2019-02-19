require 'set'

module Ventable
  module Event
    module ClassMethods

      def event(**opts, &block)
        abstract_event if opts[:abstract]
        event_name(opts[:name]) if opts[:name]
        event_symbol(opts[:symbol]) if opts[:symbol]
        notifies(opts[:notifies], &block) if opts[:notifies]
      end

      def default_event_name
        short_class_name(strip_module: true)
      end

      def event_name(name = nil)
        name = name[] if name.is_a?(Proc)
        name = name.to_sym if name

        return @event_name if @event_name && name.nil?

        if @event_name && name && @event_name != name
          Event.deregister(@event_name)
          @default_callback_methods = nil
        end

        @event_name = name ? name : (short_class_name + '_event').to_sym
        Event.register(@event_name, self)
      end

      alias event_name= event_name

      def notifies(*observer_list, &block)
        observer_list.compact!
        observers.merge(observer_list)
        observers << block if block
      end

      def event_symbol(val = nil)
        @event_symbol ||= val
      end

      alias event_symbol= event_symbol

      def callback_for(observer)
        default_callback_methods.find { |m| observer.respond_to?(m) }
      end

      private

      def abstract_event
        Event.deregister(event_name)
        @event_name = nil
      end

      def short_class_name(strip_module: true)
        @short_class_name ||= begin
          class_name = respond_to?(:name) ? name : self.class.name
          strip_module ?
            class_name.gsub(/.*::/, '').underscore.gsub(/_event$/, '') :
            class_name.gsub(/::/, '__').underscore.gsub(/_event$/, '')
        end
      end

      # Determine method name to call when notifying observers from this event.
      def default_callback_methods
        @default_callback_methods ||= [
          event_name,
          "#{event_name}_event",
          "handle_#{event_name}",
          "handle_#{event_name}_event",
          "process_#{event_name}",
          "receive_#{event_name}",
          'handle_event',
          'process_event',
        ].map(&:to_sym)
      end
    end
  end
end
