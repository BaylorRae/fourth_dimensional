require "fourth_dimensional/version"

module FourthDimensional
  class Error < StandardError; end

  autoload :AggregateRoot, 'fourth_dimensional/aggregate_root'
  autoload :Command, 'fourth_dimensional/command'
  autoload :CommandHandler, 'fourth_dimensional/command_handler'
  autoload :Configuration, 'fourth_dimensional/configuration'
  autoload :Event, 'fourth_dimensional/event'
  autoload :Eventable, 'fourth_dimensional/eventable'
  autoload :EventLoaders, 'fourth_dimensional/event_loaders'
  autoload :Repository, 'fourth_dimensional/repository'

  # The singleton instance of Configuration
  def self.config
    @configuration ||= Configuration.new
  end

  # Yields the Configuration instance
  #
  #   FourthDimensional.configure do |config|
  #     config.command_handlers = [
  #       CommentCommandHandler,
  #       PostCommandHandler
  #     ]
  #   end
  def self.configure
    yield config
  end

  # Iniitlaizes a Repository with the required dependencies.
  #
  #   FourthDimensional.repository # => FourthDimensional::Repository
  def self.build_repository
    Repository.new(event_loader: config.event_loader)
  end

  # Runs a single or array of commands through all command handlers, saves
  # commands and applied events, and invokes event handlers.
  #
  #   Fourthdimensional.execute_command(command)
  #   FourthDimensional.execute_commands(command1, command2)
  #   FourthDimensional.execute_commands([command1, command2])
  def self.execute_commands(*commands)
    repository = build_repository
    call_command_handlers(repository, commands)
    save_commands_and_events(repository)
  end

  class << self
    alias_method :execute_command, :execute_commands
  end

  private

  def self.call_command_handlers(repository, commands)
    config.command_handlers.each do |command_handler|
      commands.flatten.each do |command|
        command_handler.new(repository: repository).call(command)
      end
    end
  end

  def self.save_commands_and_events(repository)
    config.event_loader.save_commands_and_events(
      commands: repository.called_commands,
      events: repository.applied_events
    )
  end
end
