require 'set'
require 'thread'
require 'logger'

require_relative 'event/class_methods'
require_relative 'event/instance_methods'

module Ventable
  module Event

    @mutex      ||= Mutex.new
    @event_hash ||= {}
    @event_set  ||= Set.new
    @queue      ||= Queue.new

    class << self
      attr_reader :event_hash, :event_set, :mutex, :queue

      def included(base)
        base.instance_eval do
          class << self
            attr_accessor :observers
          end
        end

        mutex.synchronize do
          base.observers ||= Set.new
        end

        base.include(InstanceMethods)
        base.extend(ClassMethods)

        base.event_name = base.default_event_name
        register(base.event_name, base)
      end

      def register(event_name, event)
        event_name = event_name.to_sym
        mutex.synchronize do
          if event_hash[event_name] && event_hash[event_name] != event
            raise Ventable::Errors::DuplicateEventName.new(event_name, event_hash[event_name], event)
          end
          event_hash[event_name] = event
          cleanup_event_hash(event_name, event)
          self.event_set << event
        end
      end

      def deregister(event_name)
        mutex.synchronize do
          event = event_hash.delete(event_name)
          event_set.delete(event) if event
        end
      end

      def method_missing(method, *args, &block)
        event(method) || super
      end

      def async_alive?
        async_processor.alive?
      end

      def event(name)
        search_event(name.to_sym)
      end

      private

      def search_event(name)
        search_hash(name) || search_set(name)
      end

      def search_hash(name)
        ::Ventable::Event.event_hash[name.to_sym]
      end

      def search_set(name)
        ::Ventable::Event.event_set.find { |e| e.event_name == name.to_sym }.tap do |result|
          register(result.event_name, result) if result
        end
      end

      def cleanup_event_hash(event_name, event)
        event_hash.keys.select { |k| event_hash[k] == event && k != event_name }.each do |key|
          event_has.delete(key)
        end
      end
    end
  end
end
