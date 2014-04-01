require "ventable/version"
require "ventable/event"

module Ventable

  def self.disable
    @disabled = true
  end

  def self.enable
    @disabled = false
  end

  def self.enabled?
    @disabled != true
  end
end

class String
  def underscore
    self.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
        gsub(/([a-z\d])([A-Z])/, '\1_\2').
        tr("-", "_").
        downcase
  end
end
