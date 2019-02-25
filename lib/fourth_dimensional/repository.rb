module FourthDimensional
  # == FourthDimensional::Repository
  #
  # Event sourcing is a good application for the repository pattern since we
  # need to have a single source track commands and events being applied to the
  # system.
  #
  # The FourthDimensional::Repository is a wrapper around loading and persisting
  # events/commands with dependency injection. This allows new repositories to
  # be defined and easily registered.
  #
  # The loading and persisting of events/commands are separated to allow
  # separating the reading and writing databases should that become necessary.
  #
  #   class InMemoryEvents
  #     attr_reader :events
  #
  #     def initialize
  #       @events = []
  #     end
  #     
  #     def self.instance
  #       @instance ||= InMemoryEvents.new
  #     end
  #   end
  #
  #   class InMemoryEventLoader
  #     def for_aggregate(aggregate_id)
  #       InMemoryEvents.events
  #         .filter { |event| event.aggregate_id == aggregate_id }
  #     end
  #
  #     def save_command(command)
  #       # noop
  #     end
  #
  #     def save_events(events)
  #       InMemoryEvents.events.concat(events)
  #     end
  #   end
  #
  #   FourthDimensional.configure do |config|
  #     config.event_loader = InMemoryEventLoader.new
  #   end
  class Repository
    # The source to load events
    attr_reader :event_loader
    
    def initialize(event_loader:)
      @event_loader = event_loader
    end

    # Delegates to +event_loader#for_aggregate+
    #
    #   FourthDimensional.repository.events_for_aggregate(aggregate_id)
    def events_for_aggregate(aggregate_id)
      event_loader.for_aggregate(aggregate_id)
    end

    # Loads events from +event_loader+ and applies them to a new instance of
    # +aggregate_class+
    #
    #   FourthDimensional.repository.load_aggregate(PostAggregate, aggregate_id) # => PostAggregate
    def load_aggregate(aggregate_class, aggregate_id)
      events_for_aggregate(aggregate_id)
        .reduce(aggregate_class.new(id: aggregate_id)) do |aggregate, event|
          aggregate.apply_existing_event(event)
          aggregate
        end
    end

    # Saves the command and events with the +event_loader+
    #
    #   repository.save_command_and_events(FourthDimensional::CommandHandler::CommandAndEvents.new(
    #     command: AddPost,
    #     events: [PostAdded]
    #   ))
    def save_command_and_events(command_and_events)
      event_loader.save_command(command_and_events.command)
      event_loader.save_events(command_and_events.events)
    end
  end
end
