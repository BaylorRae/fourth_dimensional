require "fourth_dimensional/version"

module FourthDimensional
  class Error < StandardError; end

  autoload :AggregateRoot, 'fourth_dimensional/aggregate_root'
  autoload :Event, 'fourth_dimensional/event'
  autoload :Eventable, 'fourth_dimensional/eventable'
end
