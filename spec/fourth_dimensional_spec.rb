describe FourthDimensional do
  it "has a version number" do
    expect(FourthDimensional::VERSION).not_to be nil
  end

  context "config" do
    it "has a singleton configuration" do
      expect(FourthDimensional.config).to be_instance_of(FourthDimensional::Configuration)
      expect(FourthDimensional.config).to be(FourthDimensional.config)
    end
  end

  context "configure" do
    it "yields the configuration" do
      event_loader = double(:event_loader)

      FourthDimensional.configure do |config|
        config.event_loader = event_loader
      end

      expect(FourthDimensional.config.event_loader).to eq(event_loader)
    end
  end
end
