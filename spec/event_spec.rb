require "spec_helper"

module FourthDimensional
  describe Event do
    let(:aggregate_id) { double(:aggregate_id) }

    context "aggregate_id" do
      it "requires an aggregate id on initialize" do
        expect do
          Event.new
        end.to raise_error(ArgumentError, "missing keyword: aggregate_id")

        event = Event.new(aggregate_id: aggregate_id)
        expect(event.aggregate_id).to eq(aggregate_id)
      end
    end

    context "data" do
      it "has data" do
        data = { this: 'that' }

        event = Event.new(aggregate_id: aggregate_id, data: data)
        expect(event.data).to eq({'this' => 'that'})
      end

      it "defaults to a hash" do
        event = Event.new(aggregate_id: aggregate_id)
        expect(event.data).to eq({})
      end
    end

    context "metadata" do
      it "has metadata" do
        metadata = { foo: 'bar' }

        event = Event.new(aggregate_id: aggregate_id, metadata: metadata)
        expect(event.metadata).to eq({'foo' => 'bar'})
      end

      it "defaults to a hash" do
        event = Event.new(aggregate_id: aggregate_id)
        expect(event.metadata).to eq({})
      end
    end
  end
end
