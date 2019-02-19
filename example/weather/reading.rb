module Weather
  class Reading
    def self.inherited(base)
      base.instance_eval do
        class << self
          attr_reader :units

          def units(val = nil)
            val ? @units = val : @units
          end
        end
      end
    end

    attr_reader :value, :timestamp

    def initialize(sensor_value)
      @value     = sensor_value
      @timestamp = Time.now
    end

    def to_s
      "#{self.class.name.gsub(/.*::/, '').underscore.capitalize} is at #{'%.2d' % value}#{self.class.units}"
    end
  end
end

require_relative 'readings/cloud_cover'
require_relative 'readings/temperature'
require_relative 'readings/precipitation'
