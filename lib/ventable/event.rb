# frozen_string_literal: true

require 'set'
require 'active_support/inflector'

module ::Ventable
  class Error < RuntimeError
  end

  module Event
    def self.included(klass)
      klass.instance_eval do
        @observers = Set.new
        class << self
          attr_accessor :observers
        end
      end

      klass.extend ClassMethods
    end

    def fire!
      notify_observer_set(self.class.observers) if Ventable.enabled?
    end

    alias publish fire!

    private

    def notify_observer_set(observer_set)
      observer_set.each do |observer_entry|
        if observer_entry.is_a?(Hash)
          around_block = observer_entry[:around_block]
          around_block&.call(-> { notify_observer_set(observer_entry[:observers]) })
        else
          notify_observer(observer_entry)
        end
      end
    end

    def notify_observer(observer)
      case observer
      when Proc
        observer.call(self)
      else # class
        notify_class_observer(observer)
      end
    end

    def notify_class_observer(observer)
      default_handler = self.class.send(:default_callback_method)
      return observer.send(default_handler, self) if observer.respond_to?(default_handler)
      return observer.send(:handle_event, self) if observer.respond_to?(:handle_event)

      raise Ventable::Error, "no suitable event handler method found for #{self.class} in observer #{observer} (try adding #{default_handler} to this observer)"
    end

    module ClassMethods
      def configure(&block)
        class_eval(&block)
      end

      def notifies(*observer_list, **options, &block)
        observer_set = observers
        if options[:inside]
          observer_entry = find_observer_group(options[:inside])
          raise Ventable::Error, "No group with name #{options[:inside]} found." if observer_entry.nil?

          observer_set = observer_entry[:observers]
        end
        raise Ventable::Error, "found nil observer in params #{observer_list.inspect}" if observer_list.any?(&:nil?)

        observer_list.compact.each { |o| observer_set << o } unless observer_list.empty?
        observer_set << block if block
      end

      def group(name, &block)
        observers << { name: name,
                       around_block: block,
                       observers: Set.new }
      end

      protected

      def find_observer_group(name)
        observers.find { |o| o.is_a?(Hash) && o[:name] == name }
      end

      private

      # Determine method name to call when notifying observers from this event.
      def default_callback_method
        if respond_to?(:ventable_callback_method_name)
          ventable_callback_method_name
        else
          target = self

          method = "handle_#{ActiveSupport::Inflector.underscore(target.name)}".
                   gsub(%r{/([^/]*)}, '__\1').
                   gsub(/_event$/, '')

          method.to_sym
        end
      end
    end
  end
end
