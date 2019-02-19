# coding: utf-8
require_relative 'event'
require 'json'
module Weather
  module Conditions
    class Condition < Event
      attr_accessor :probability, :state

      class << self
        def inherited(base)
          base.instance_eval do
            include ::Ventable::Event
          end
        end
      end

      def initialize(probability, readings)
        self.probability, self.state = probability, readings
      end

      def to_s
        <<-eof
┌──────────┐  
│   #{my_event_symbol}     │  There is a #{'%.2d'.bold.red % probability} chance of #{my_event_name.to_s.upcase.bold.yellow} | Readings are: #{state.to_h.to_s.bold.blue}         
└──────────┘

eof

      end

      def publish
        puts self.to_s
        super
      end
    end
  end
end

require_relative 'condition'
require_relative 'conditions/cloudy'
require_relative 'conditions/raining'
require_relative 'conditions/sunny'
require_relative 'conditions/snowing'

