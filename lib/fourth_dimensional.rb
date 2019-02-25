require "fourth_dimensional/version"

module FourthDimensional
  class Error < StandardError; end

  autoload :AggregateRoot, 'fourth_dimensional/aggregate_root'
  autoload :Command, 'fourth_dimensional/command'
  autoload :CommandHandler, 'fourth_dimensional/command_handler'
  autoload :Event, 'fourth_dimensional/event'
  autoload :Eventable, 'fourth_dimensional/eventable'
  autoload :Repository, 'fourth_dimensional/repository'
end
