require 'ventable'
require 'ventable/broadcaster'
require_relative 'event'
require_relative 'condition'
require_relative 'reading'

require 'awesome_print'

module Weather
  class Observatory

    class CurrentReading < Struct.new(:temperature, :precipitation, :cloud_cover)
    end

    srand Time.now.to_i

    attr_accessor :readings, :current_reading, :shutdown

    include ::Ventable::Broadcaster
    include ::Ventable::Observer

    observe :cloudy, :raining, :snowing, :sunny

    def self.handle_event(event)
      puts "   >>> Received Event: #{event.my_event_name}"
    end

    def initialize
      @readings        = []
      @current_reading = CurrentReading.new
      @shutdown        = false

      trap('INT') {
        puts 'trapping INT'
        self.shutdown = true
        Ventable.shutdown!
      }

      run
    end

    def run
      loop do
        if shutdown
          puts 'Observatory is going offline'
          break
        end
        observe
        analyze
        puts
        sleep 2
      end
    end

    def observe
      self.readings << Readings::Temperature.new(rand(30) - 10)
      self.readings << Readings::Precipitation.new(rand(100))
      self.readings << Readings::CloudCover.new(rand(100))
    end

    def analyze
      process_readings!

      if (50..100).include?(current_reading.precipitation)
        if current_reading.temperature.positive?
          broadcast :raining, current_reading.precipitation, current_reading
        else
          broadcast :snowing, current_reading.precipitation, current_reading
        end
      else
        if (50..100).include?(current_reading.cloud_cover)
          broadcast :cloudy, current_reading.cloud_cover, current_reading
        else
          broadcast :sunny, 100 - current_reading.cloud_cover, current_reading
        end
      end

      readings.clear
      current_reading
    end

    private

    def process_readings!
      readings.each do |state|
        case state
        when Readings::Temperature
          current_reading.temperature = state.value
        when Readings::Precipitation
          current_reading.precipitation = state.value
        when Readings::CloudCover
          current_reading.cloud_cover = state.value
        else
          raise "Unrecognized weather sensor reading type: #{state}"
        end
      end
    end
  end
end

Weather::Observatory.new
