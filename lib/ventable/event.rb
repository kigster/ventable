require 'set'

module ::Ventable
  module Event
    OBSERVERS = Hash.new

    class ObserverRegistration < Struct.new(:observer, :method);
    end

    def self.reset!
      OBSERVERS.clear
    end

    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def fire!
        if self.respond_to?(:around_fire)
          self.around_fire do
            _fire
          end
        else
          _fire
        end
      end

      def _fire
        observer_registrations = ::Ventable::Event::OBSERVERS[self.class.name] || []
        observer_registrations.each do |observer_registration|
          target = observer_registration[:observer]
          if target.is_a?(Proc)
            target.call(self)
          else
            target.send(observer_registration[:method], self)
          end
        end
      end
    end

    module ClassMethods
      def observed_by observer = nil, method = nil, &block
        ::Ventable::Event::OBSERVERS[self.name] ||= Set.new
        new_registration = if block && !observer
                             ObserverRegistration.new(block, nil)
                           else
                             method = default_callback_method unless method.is_a?(Symbol)
                             ObserverRegistration.new(observer, method)
                           end
        ::Ventable::Event::OBSERVERS[self.name] << new_registration
      end

      def create_event(*args, &block)
        self.new block.call
      end

      def default_callback_method
        _target = self
        _method = "handle_" + _target.name.underscore.gsub(/_event/, '') + "_event"
        _method.to_sym
      end
    end
  end
end
