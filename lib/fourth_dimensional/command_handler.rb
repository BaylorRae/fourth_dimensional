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
  #     # manually load and save aggregate
  #     on UpdateTitle do |command|
  #       post = repository.load_aggregate(PostAggregate, command.aggregate_id)
  #       post.update_title(title: command.title)
  #       save(command, post)
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

    class CommandAndEvents
      attr_reader :command, :events

      def initialize(command:, events:)
        @command = command
        @events = events
      end

      def ==(other)
        self.class == other.class && command == other.command && events == other.events
      end
    end

    def initialize(repository:)
      @repository = repository
    end

    # Invokes a callback for an command.
    def call(command)
      callback = self.class.event_bindings[command.class]
      return if callback.nil?
      instance_exec(command, &callback)
    end

    # Yields the aggregate and saves the applied events
    def with_aggregate(aggregate_class, command, &block)
      aggregate = repository.load_aggregate(aggregate_class, command.aggregate_id)
      yield aggregate
      save(command, aggregate)
    end

    # Saves the command and aggregate's applied events
    #
    #   class PostCommandHandler < FourthDimensional::CommandHandler
    #     on AddPost do |command|
    #       post = repository.load_aggregate(PostAggregate, command.aggregate_id)
    #       post.add(title: command.title)
    #       save(command, post)
    #     end
    #   end
    def save(command, aggregate)
      repository.save_command_and_events(CommandAndEvents.new(
        command: command,
        events: aggregate.applied_events
      ))
    end
  end
end
