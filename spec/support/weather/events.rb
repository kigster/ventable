class GenericEvent
  include Ventable::Event
end

module Weather
  class << self
    attr_accessor :latest_weather_event

    def print_current_weather
      latest_weather_event ? latest_weather_event.current_weather : 'Weather is unknown'
    end
  end

  class WeatherEvent < GenericEvent
    attr_reader :temperature

    def initialize(temperature)
      @temperature = temperature
    end

    def publish(*args)
      super(*args)
      Weather.latest_weather_event = self
    end

    def current_weather
      puts "It's #{event_name} at #{'%.2fºF' % temperature} at the moment."
    end
  end

  module Events
    class Snowing < ::WeatherEvent
      event_name :its_snowing
    end

    class Raining < ::WeatherEvent
      event_name :its_raining
    end

    class Sunny < ::WeatherEvent
      event_name :its_sunny
    end
  end
end
