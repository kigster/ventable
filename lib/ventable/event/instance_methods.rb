require 'set'

module ::Ventable
  module Event
    module InstanceMethods
      def fire(*args, **opts, &block)
        if Ventable.enabled?
          notify_observer_set(self.class.observers, *args, **opts, &block)
        else
          true
        end
      end

      def fire!(*args, **opts, &block)
        fire(*args, **opts, &block).tap do |result|
          raise Errors::FireError, 'Error'
        end
      end

      alias publish fire

      private

      def notify_observer_set(observer_set, *args, **opts, &block)
        observer_set.each do |observer_entry|
          if observer_entry.is_a?(Hash)
            around_block = observer_entry[:around_block]
            inside_block = -> { notify_observer_set(observer_entry[:observers]) }
            around_block.call(inside_block)
          else
            notify_observer(observer_entry, *args, **opts, &block)
          end
        end
      end

      def notify_observer(observer, *args, **opts, &block)
        arguments = [observer, *args].compact
        case observer
        when Proc
          observer.call(*arguments, **opts, &block)
        else # class
          notify_class_observer(observer, *args, **opts, &block)
        end
      end

      def notify_class_observer(observer, *args, **opts, &block)
        method = event_callback_method(observer)
        raise(Ventable::Error.new("no suitable event handler method found for #{self.class} in observer #{observer}")) if method.nil?
        observer.send(method, self, *args, **opts, &block)
      end

      def event_callback_method(observer)
        self.class.send(:default_callback_methods).select do |method_name|
          observer.respond_to?(method_name)
        end
      end
    end
  end
end
