Rails.configuration.to_prepare do
  FourthDimensional.configure do |config|
    config.event_loader = FourthDimensional::EventLoaders::ActiveRecord.new
    config.command_handlers = []
    config.event_handlers = []
  end
end
