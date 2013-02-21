require 'set'

module ::Ventable
  module Event
    def self.included(klazz)
      klazz.instance_eval do
        @observers = Set.new
        class << self
          attr_accessor :observers
        end
      end

      klazz.extend ClassMethods
    end

    def fire!
      notify_observer_set(self.class.observers)
    end

    private

    def notify_observer_set(observer_set)
      observer_set.each do |observer_entry|
        if observer_entry.is_a?(Hash)
          around_block = observer_entry[:around_block]
          inside_block = -> { notify_observer_set(observer_entry[:observers]) }
          around_block.call(inside_block)
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
      observer.respond_to?(self.class.default_callback_method) ?
          observer.send(self.class.default_callback_method, self) :
          observer.send(:handle_event, self)
    end

    module ClassMethods
      def configure(&block)
        class_eval(&block)
      end

      def notifies(*observer_list, &block)
        options = {}
        options.merge! observer_list.pop if observer_list.last.is_a?(Hash)
        observer_set = self.observers
        if options[:inside]
          observer_entry = self.find_observer_group(options[:inside])
          observer_set = observer_entry[:observers]
        end
        observer_list.each { |o| observer_set << o } unless observer_list.empty?
        observer_set << block if block
      end

      def group(name, &block)
        raise "Group #{name} already defined by #{g}" if  find_observer_group(name)
        self.observers <<
            { name: name,
              around_block: block,
              observers: Set.new
            }
      end

      def find_observer_group(name)
        self.observers.find { |o| o.is_a?(Hash) && o[:name] == name }
      end

      def default_callback_method
        target = self
        method = "handle_" + target.name.gsub(/.*::/,'').underscore.gsub(/_event/, '') + "_event"
        method.to_sym
      end
    end
  end
end
