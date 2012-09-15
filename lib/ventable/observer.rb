module Ventable
  module Observer
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def observe event, method = nil
        event.observed_by self, method
      end
    end
  end
end
