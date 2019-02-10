require 'set'

module Ventable
  module Publisher
    def self.included(klass)
      class << self
        def publish(event_name, *args, **opts, &block)
          Ventable.event(event_name).fire(*args, **opts, &block)
        end
      end
    end
  end
end
