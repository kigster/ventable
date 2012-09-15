require 'ventable'

describe Ventable do

  after do
    Ventable::Event.reset!
  end

  describe "when event fires" do
    before do
      class WakeUpEvent
        include Ventable::Event
        attr_accessor :wakeup_time, :user

        def initialize(user, wakeup_time)
          self.user = user
          self.wakeup_time = wakeup_time
        end
      end

      class Mom
        include Ventable::Observer
        observe WakeUpEvent

        def self.handle_wake_up_event(event)
          # start making breakfast for #{event.user}
        end
      end

      class Boss
        def self.discipline_employee(user)
          # tell them!
        end
        def self.handle_wake_up_event(event)
          if event.wakeup_time.hour > 9
            self.discipline_employee(event.user)
          end
        end
      end

      WakeUpEvent.observed_by Boss

      @event = WakeUpEvent.new(Struct.new(:first,:last).new("John", "Doe"), Time.now)
      @event.should be_kind_of(WakeUpEvent)
    end

    it "notifies all observers with default hander method" do
      [Boss, Mom].each {|clazz| clazz.should_receive(:handle_wake_up_event).with(@event).once }
      #Boss.should_receive(:handle_wake_up_event).with(@event).once
      #Mom.should_receive(:handle_wake_up_event).with(@event).once
      @event.fire!
    end


    it "notifies all observers with custom handler method" do
      class CustomObserver
        def custom_method; end
      end
      CustomObserver.should_receive(:custom_method).with(@event).once
      WakeUpEvent.observed_by CustomObserver, :custom_method
      @event.fire!
    end

    it "notifies observers added as a proc" do
      @called = false
      WakeUpEvent.observed_by do
        @called = true
      end

      @event.fire!
      @called.should be_true
    end
  end

  describe "event with around_fire block" do
    it "executes around fire before firing event" do
      module EventBencharker
        attr_accessor :last_elapsed_time
        def around_fire &block
          start = Time.now
          yield if block_given?
          self.last_elapsed_time = Time.now - start
          # puts "event #{self.to_s} took #{last_elapsed_time} seconds"
        end
      end
      class FallAsleepEvent
        include Ventable::Event
        include EventBencharker
      end

      class LightsOffObserver
        def turn_off_lights event; end
      end

      @observer = LightsOffObserver.new

      FallAsleepEvent.observed_by @observer, :turn_off_lights

      @event = FallAsleepEvent.new

      @observer.should_receive(:turn_off_lights).with(@event).once
      @event.last_elapsed_time.should be_nil

      @event.fire!
      @event.last_elapsed_time.should_not be_nil
    end
  end

  describe "default callback method name helper" do
    it "generates a correct method name" do
      class OneTwoEvent
        include Ventable::Event
      end
      class ThreeFour < OneTwoEvent
      end

      OneTwoEvent.default_callback_method.should be(:handle_one_two_event)
      ThreeFour.default_callback_method.should be(:handle_three_four_event)
    end
  end
end
