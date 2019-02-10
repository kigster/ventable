require 'set'

require_relative 'event/class_methods'
require_relative 'event/instance_methods'

module Ventable
  module Event
    @event_hash = {}
    @event_set  = Set.new

    class << self
      attr_reader :event_hash, :event_set

      def included(base)
        base.instance_eval do
          @observers = Set.new
          class << self
            attr_accessor :observers
          end
        end

        base.include(InstanceMethods)
        base.extend(ClassMethods)

        self.event_set << base
        self.event_hash[base.event_name] = base
      end

    end
  end
end
