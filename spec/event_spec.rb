require "spec_helper"

module FourthDimensional
  describe Event do
    let(:aggregate_id) { double(:aggregate_id) }
    
    context "type" do
      it "has a pretty type" do
        stub_const("This::Is::Not::APrettyEvent", Class.new(Event))
        expect(This::Is::Not::APrettyEvent.new(aggregate_id: 1).type).to eq('this/is/not/a_pretty_event')
      end
    end

    context "aggregate_id" do
      it "requires an aggregate id on initialize" do
        expect do
          Event.new
        end.to raise_error(ArgumentError, "missing keyword: aggregate_id")

        event = Event.new(aggregate_id: aggregate_id)
        expect(event.aggregate_id).to eq(aggregate_id)
      end
    end

    context "id" do
      it "has a readonly id" do
        id = double(:id)
        event = Event.new(aggregate_id: aggregate_id, id: id)
        expect(event.id).to eq(id)

        expect do
          event.id = id
        end.to raise_error(NoMethodError)
      end
    end

    context "version" do
      it "has a readonly version" do
        version = double(:version)
        event = Event.new(aggregate_id: aggregate_id, version: version)
        expect(event.version).to eq(version)

        expect do
          event.version = version
        end.to raise_error(NoMethodError)
      end
    end

    context "created_at" do
      it "has a readonly created_at" do
        created_at = double(:created_at)
        event = Event.new(aggregate_id: aggregate_id, created_at: created_at)
        expect(event.created_at).to eq(created_at)

        expect do
          event.created_at = created_at
        end.to raise_error(NoMethodError)
      end
    end

    context "updated_at" do
      it "has a readonly updated_at" do
        updated_at = double(:updated_at)
        event = Event.new(aggregate_id: aggregate_id, updated_at: updated_at)
        expect(event.updated_at).to eq(updated_at)

        expect do
          event.updated_at = updated_at
        end.to raise_error(NoMethodError)
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
