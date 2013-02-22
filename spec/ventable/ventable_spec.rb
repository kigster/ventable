require 'ventable'

describe Ventable do
  before do
    class TestEvent
      include Ventable::Event
    end
  end

  describe "including Ventable::Event" do
    it "should create a class instance variable to keep observers" do
      TestEvent.observers.should_not be_nil
      TestEvent.observers.should be_a(Set)
    end

    it "should see observers variable from instance methods" do
      observers = nil
      TestEvent.new.instance_eval do
        observers = self.class.observers
      end
      observers.should_not be_nil
    end

    it "should maintain separate sets of observers for each event" do
      class AnotherEvent
        include Ventable::Event
      end
      AnotherEvent.observers.object_id.should_not == TestEvent.observers.object_id
    end
  end

  describe "#fire" do
    before do
      class TestEvent
        include Ventable::Event
      end
    end

    it "should properly call a Proc observer" do
      run_block = false
      event = nil
      TestEvent.notifies do |e|
        run_block = true
        event = e
      end
      run_block.should_not be_true
      event.should be_nil

      # fire the event
      TestEvent.new.fire!

      run_block.should be_true
      event.should_not be_nil
    end

    it "should properly call a class observer" do
      TestEvent.instance_eval do
        class << self
          attr_accessor :flag
        end
      end

      TestEvent.class_eval do
        def set_flag!
          self.class.flag = true
        end
      end
      class TestEventObserver
        def self.handle_test event
          event.set_flag!
        end
      end
      TestEvent.notifies TestEventObserver
      TestEvent.flag.should be_false

      TestEvent.new.fire!
      TestEvent.flag.should be_true
    end

    it "should properly call a group of observers" do
      transaction_called = false
      transaction_completed = false
      transaction = ->(observer_block) {
        transaction_called = true
        observer_block.call
        transaction_completed = true
      }

      TestEvent.group :transaction, &transaction
      observer_block_called = false

      # this flag ensures that this block really runs inside
      # the transaction group block
      transaction_already_completed = false
      event_inside = nil
      TestEvent.notifies inside: :transaction do |event|
        observer_block_called = true
        transaction_already_completed = transaction_completed
        event_inside = event
      end

      transaction_called.should be_false
      transaction_already_completed.should be_false
      observer_block_called.should be_false

      TestEvent.new.fire!

      transaction_called.should be_true
      observer_block_called.should be_true
      transaction_already_completed.should be_false
      event_inside.should_not be_nil
      event_inside.should be_a(TestEvent)
    end
  end

  describe "#default_callback_method" do
    before do
      class SomeAwesomeEvent
        include Ventable::Event
      end

      module Blah
        class AnotherSweetEvent
          include Ventable::Event
        end
      end

      class SomeOtherStuffHappened
        include Ventable::Event
      end
      class ClassWithCustomCallbackMethodEvent
        include Ventable::Event

        def self.ventable_callback_method_name
          :handle_my_special_event
        end
      end
    end

    it "should properly set the callback method name" do
      SomeAwesomeEvent.default_callback_method.should == :handle_some_awesome
      Blah::AnotherSweetEvent.default_callback_method.should == :handle_blah__another_sweet
      SomeOtherStuffHappened.default_callback_method.should == :handle_some_other_stuff_happened
      ClassWithCustomCallbackMethodEvent.default_callback_method.should == :handle_my_special_event
    end
  end

  describe "#configure" do
    it "properly configures the event with observesrs" do
      notified_observer = false
      TestEvent.configure do
        notifies do
          notified_observer = true
        end
      end
      TestEvent.new.fire!
      notified_observer.should be_true
    end

    it "configures observers with groups" do
      notified_observer = false
      called_transaction = false
      TestEvent.configure do
        group :transaction, &->(b){
          b.call
          called_transaction = true
        }
        notifies inside: :transaction do
          notified_observer = true
        end
      end
      TestEvent.new.fire!
      notified_observer.should be_true
      called_transaction.should be_true
    end

    it "throws exception if :inside references unknown group" do
      begin
        TestEvent.configure do
          notifies inside: :transaction do
            # some stuff
          end
        end
        fail "Shouldn't reach here, must throw a valid exception"
      rescue Exception => e
        e.class.should == Ventable::Error
      end
    end
  end
end
