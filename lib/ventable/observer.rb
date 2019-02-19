module Ventable
  module Observer
    def self.included(base)
      base.instance_eval do
        class << self
          def observe(*event_names)
            event_names.each do |event_name|
              Ventable::Event.send(event_name).notifies(self)
            end
          end
        end
      end
    end
  end
end


