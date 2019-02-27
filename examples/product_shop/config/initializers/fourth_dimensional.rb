Rails.configuration.to_prepare do
  FourthDimensional.configure do |config|
    config.event_loader = FourthDimensional::EventLoaders::ActiveRecord.new
    config.command_handlers = [
      Products::CommandHandler
    ]
    config.event_handlers = [
      Products::ProductProjector
    ]
  end
end
