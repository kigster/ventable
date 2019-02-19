# coding: utf-8
# frozen_string_literal: true
#
# © 2018 Konstantin Gredeskoul (twitter.com/kig)
# https://github.com/kigster
#—————————————————————————————————————————————————————————————————————————————
require 'forwardable'

module Ventable
  class AsyncEventProcessor

    extend Forwardable
    attr_reader :thread
    attr_accessor :graceful_shutdown

    def_delegators :thread, :alive?, :join

    def initialize
      @thread = create_runtime_thread
    end

    def shutdown!
      self.graceful_shutdown = true
      @thread.join
      puts 'thread stopped, status is ' + @thread.to_s
    end

    private

    def create_runtime_thread
      Thread.new do
        Thread.stop if graceful_shutdown

        while ::Ventable::Event.queue.empty?
          Thread.stop if graceful_shutdown
          sleep 0.01
        end

        event = ::Ventable::Event.queue.pop

        begin
          event.publish_synchronously
        rescue Ventable::Errors::VentableError => e
          Ventable.logger.error("event publishing error for #{event.my_event_name.bold.red}, #{e.inspect.red}")
          Ventable.logger.warning('ignoring error and continueing...')
        end
      end
    end
  end
end
