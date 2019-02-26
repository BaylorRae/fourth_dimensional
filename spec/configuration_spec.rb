require "spec_helper"

module FourthDimensional
  describe Configuration do
    it "has default values" do
      expect(subject.command_handlers).to eq([])
      expect(subject.event_handlers).to eq([])
      expect(subject.event_loader).to be_nil
      expect(subject.table_prefix).to eq('fourd_')
    end

    it "has assignable attributes" do
      subject.command_handlers = command_handlers = double(:command_handlers)
      subject.event_handlers = event_handlers = double(:event_handlers)
      subject.event_loader = event_loader = double(:event_loader)
      subject.table_prefix = table_prefix = double(:table_prefix)

      expect(subject.command_handlers).to eq(command_handlers)
      expect(subject.event_handlers).to eq(event_handlers)
      expect(subject.event_loader).to eq(event_loader)
      expect(subject.table_prefix).to eq(table_prefix)
    end
  end
end
