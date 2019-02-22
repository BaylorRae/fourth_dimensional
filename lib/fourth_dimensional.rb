require "fourth_dimensional/version"

module FourthDimensional
  class Error < StandardError; end

  autoload :Event, 'fourth_dimensional/event'
end
