require 'ventable/version'
require 'ventable/errors'
require 'ventable/observer'
require 'ventable/event'
require 'ventable/publisher'
require 'extensions'

module Ventable
  @enabled = true

  class << self
    attr_accessor :enabled

    def event(name)
      search_event(name.to_sym)
    end

    def disable!
      self.enabled = false
    end

    def enable!
      self.enabled = true
    end

    alias enabled? enabled

    def disabled?
      !enabled?
    end

    private

    def search_event(name)
      event_from_hash = ::Ventable::Event.event_hash[name]
      (event_from_hash || ::Ventable::Event.event_set.select { |e| e.event_name == name }).tap do |event_from_set|
        ::Ventable::Event.event_hash[name] = event_from_set if event_from_set && event_from_hash.nil?
      end
    end
  end
end
