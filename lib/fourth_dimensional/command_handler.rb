module FourthDimensional
  # == FourthDimensional::CommandHandler
  #
  # Command handlers have bindings that wrap a Command to load an aggregate and
  # apply events.
  #
  #   class PostCommandHandler < FourthDimensional::CommandHandler
  #     on AddPost do |command|
  #       with_aggregate(PostAggregate, command) do |post|
  #         post.add(title: command.title, body: command.body)
  #       end
  #     end
  #
  #     on UpdateTitle do |command|
  #       with_aggregate(PostAggregate, command) do |post|
  #         post.update_title(title: command.title)
  #       end
  #     end
  #
  #     on PublishPost do |command|
  #       with_aggregate(PostAggregate, command) do |post|
  #         post.publish
  #       end
  #     end
  #   end
  class CommandHandler
    include Eventable

    attr_reader :repository

    CommandAndEvents = Struct.new(:command, :events, keyword_init: true)

    def initialize(repository:)
      @repository = repository
    end

    # Invokes a callback for an command.
    def call(command)
      callback = self.class.event_bindings[command.class]
      return if callback.nil?
      instance_exec(command, &callback)
      @called_command = command
    end

    # Yields the aggregate and saves the applied events
    def with_aggregate(aggregate_class, command, &block)
      aggregate = repository.load_aggregate(aggregate_class, command.aggregate_id)
      yield aggregate
      applied_events.concat(aggregate.applied_events)
    end

    # Returns the command and applied events in a CommandAndEvents
    def tracked_command_and_events
      CommandAndEvents.new(command: @called_command,
                           events: applied_events)
    end

    private

    def applied_events
      @applied_events ||= []
    end
  end
end
