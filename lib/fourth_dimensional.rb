require "fourth_dimensional/version"

module FourthDimensional
  class Error < StandardError; end

  autoload :AggregateRoot, 'fourth_dimensional/aggregate_root'
  autoload :Command, 'fourth_dimensional/command'
  autoload :CommandHandler, 'fourth_dimensional/command_handler'
  autoload :Configuration, 'fourth_dimensional/configuration'
  autoload :Event, 'fourth_dimensional/event'
  autoload :Eventable, 'fourth_dimensional/eventable'
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
end
