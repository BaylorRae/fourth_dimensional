module FourthDimensional
  # == FourthDimensional::Configuration
  #
  #   FourthDimensional.configure do |config|
  #     config.command_handlers = [...]
  #     config.event_handlers = [...]
  #     config.event_loader = FourthDimensional::ActiveRecord::EventLoader.new
  #   end
  class Configuration
    # An array of command handlers
    attr_accessor :command_handlers

    # An array of event handlers
    attr_accessor :event_handlers

    # The event loader
    attr_accessor :event_loader
  end
end
