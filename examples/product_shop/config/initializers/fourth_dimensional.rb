FourthDimensional.configure do |config|
  config.event_loader = FourthDimensional::EventLoaders::ActiveRecord.new
  config.command_handlers = [
    Products::CommandHandler
  ]
end
