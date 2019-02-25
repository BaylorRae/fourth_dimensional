require "spec_helper"

module FourthDimensional
  describe Configuration do
    it "has assignable attributes" do
      subject.command_handlers = command_handlers = double(:command_handlers)
      subject.event_handlers = event_handlers = double(:event_handlers)
      subject.event_loader = event_loader = double(:event_loader)

      expect(subject.command_handlers).to eq(command_handlers)
      expect(subject.event_handlers).to eq(event_handlers)
      expect(subject.event_loader).to eq(event_loader)
    end
  end
end
