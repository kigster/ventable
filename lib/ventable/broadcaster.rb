require 'set'

module Ventable
  module Broadcaster
    def self.included(klass)
      klass.class_eval do
        def broadcast(event_name, *args)
          Ventable::Event.event(event_name).new(*args).publish
        end

        alias fire broadcast
      end
    end
  end
end
