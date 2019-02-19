require 'ventable/version'
require 'ventable/errors'
require 'ventable/observer'
require 'ventable/event'
require 'ventable/broadcaster'
require 'ventable/async_processor'
require 'extensions'

module Ventable
  @enabled         ||= true
  @logger          ||= Logger.new(STDOUT)
  @async_processor ||= AsyncEventProcessor.new

  class << self
    attr_accessor :enabled, :logger, :async_processor

    def configure(&block)
      class_eval(&block)
    end

    def disable!
      self.enabled = false
    end

    def enable!
      self.enabled = true
    end

    def shutdown!
      async_processor.shutdown!
    end

    alias enabled? enabled

    def disabled?
      !enabled?
    end
  end
end
