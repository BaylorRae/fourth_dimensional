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
    after do
      FourthDimensional.config.event_loader = nil
    end

    it "yields the configuration" do
      event_loader = double(:event_loader)

      FourthDimensional.configure do |config|
        config.event_loader = event_loader
      end

      expect(FourthDimensional.config.event_loader).to eq(event_loader)
    end
  end

  context "repository" do
    after do
      FourthDimensional.config.event_loader = nil
    end

    it "loads a repository with the event loader" do
      FourthDimensional.config.event_loader = event_loader = double(:event_loader)

      repository = FourthDimensional.build_repository
      expect(repository).to be_instance_of(FourthDimensional::Repository)
      expect(repository.event_loader).to eq(event_loader)
    end
  end
end
