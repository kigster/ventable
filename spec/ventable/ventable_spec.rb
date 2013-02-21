require 'ventable'
require 'pp'
describe Ventable do

  describe "including Ventable::Event" do
    before do
      class TestEvent
        include Ventable::Event
      end
    end

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
        def self.handle_test_event event
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
      transaction = ->(observer_block){
        transaction_called = true
        observer_block.call
        transaction_completed = true
      }

      TestEvent.group :transaction, &transaction
      observer_block_called = false

      # this flag ensures that this block really runs inside
      # the transaction group block
      transaction_already_completed = false
      TestEvent.notifies inside: :transaction do |event|
        observer_block_called = true
        transaction_already_completed = transaction_completed
      end

      transaction_called.should be_false
      transaction_already_completed.should be_false
      observer_block_called.should be_false

      TestEvent.new.fire!

      transaction_called.should be_true
      observer_block_called.should be_true
      transaction_already_completed.should be_false
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
    end

    it "should properly set the callback method name" do
      SomeAwesomeEvent.default_callback_method.should == :handle_some_awesome_event
      Blah::AnotherSweetEvent.default_callback_method.should == :handle_another_sweet_event
    end
  end

end
