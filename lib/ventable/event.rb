module ::Ventable
  module Event
    OBSERVERS = Hash.new

    class ObserverRegistration < Struct.new(:observer, :method);end

    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def fire!
        observer_registrations = ::Ventable::Event::OBSERVERS[self.class.name] || []
        observer_registrations.each do |observer_registration|
          observer_registration[:observer].send(observer_registration[:method] || :handle_event, self)
        end
      end
    end

    module ClassMethods

      def observe_by observer, method = nil
        ::Ventable::Event::OBSERVERS[self.name] ||= []
        ::Ventable::Event::OBSERVERS[self.name] << ObserverRegistration.new(observer, method)
      end

      def create_event(*args, &block)
        self.new block.call
      end
    end
  end
end
