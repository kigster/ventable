module Weather
  class Event
    include ::Ventable::Event

    event abstract: true, name: -> { default_event_name }
  end
end

