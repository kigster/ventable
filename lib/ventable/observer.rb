module Ventable
  module Event
    class Observer
      attr_reader :target

      def initialize(target)
        @target = target
      end
    end

    class ObserverGroup < Observer
      attr_reader :observers

      def initialize(*args, &block)
        @observers = Set.new
        args.each do |arg|
          @observers << Observer.new(arg)
        end
        @observers << Observer.new(block) if block
      end
    end
  end
end


