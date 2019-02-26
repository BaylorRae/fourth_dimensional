require "spec_helper"

module FourthDimensional
  describe AggregateRoot do
    let(:id) { double(:id) }
    let(:aggregate) { ExampleAggregate.new(id: id) }

    before do
      stub_const("Added", Class.new(Event))
      stub_const("Deleted", Class.new(Event))
      stub_const("ExampleAggregate", Class.new(AggregateRoot))

      ExampleAggregate.class_eval do
        attr_reader :state

        def initialize(*args)
          super

          @state = :initial
        end

        def add
          apply Added
        end

        def delete
          apply Deleted
        end

        on Added do |event|
          @state = :added
        end

        on Deleted do |event|
          @state = :deleted
        end
      end
    end

    context "id" do
      it "has a required id" do
        expect do
          AggregateRoot.new
        end.to raise_error(ArgumentError, "missing keyword: id")

        id = double(:id)
        aggregate = AggregateRoot.new(id: id)
        expect(aggregate.id).to eq(id)
      end
    end

    context "apply" do
      it "calls bindings on object" do
        expect(aggregate.state).to eq(:initial)

        aggregate.add
        expect(aggregate.state).to eq(:added)

        aggregate.delete
        expect(aggregate.state).to eq(:deleted)
      end

      it "tracks applied events" do
        expect(aggregate.applied_events).to eq([])

        aggregate.add
        expect(aggregate.applied_events.length).to eq(1)

        aggregate.delete
        expect(aggregate.state).to eq(:deleted)
        expect(aggregate.applied_events.length).to eq(2)

        expect(aggregate.applied_events.map(&:aggregate_id)).to eq([
          id,
          id
        ])
      end

      it "creates events with data and metadata" do
        stub_const("DataEvent", Class.new(Event))
        stub_const("MetaDataEvent", Class.new(Event))
        stub_const("AllDataEvent", Class.new(Event))

        none_callback = -> (event) {}

        ExampleAggregate.class_eval do
          on DataEvent, &none_callback
          on MetaDataEvent, &none_callback
          on AllDataEvent, &none_callback
        end

        aggregate.apply(DataEvent, data: { one: 1 })
        expect(aggregate.applied_events.last.data).to eq({ 'one' => 1 })

        aggregate.apply(MetaDataEvent, metadata: { two: 2 })
        expect(aggregate.applied_events.last.metadata).to eq({ 'two' => 2 })

        aggregate.apply(AllDataEvent, data: { three: 3 }, metadata: { four: 4 })
        expect(aggregate.applied_events.last.data).to eq({ 'three' => 3 })
        expect(aggregate.applied_events.last.metadata).to eq({ 'four' => 4 })
      end

      it "raises an error for unknown events" do
        stub_const("UnknownEvent", Class.new(Event))
        expect do
          aggregate.apply(UnknownEvent)
        end.to raise_error(AggregateRoot::UnknownEventError, "ExampleAggregate doesn't have a binding for 'UnknownEvent'")
      end
    end

    context "apply_existing_event" do
      it "call bindings without tracking" do
        expect(aggregate.state).to eq(:initial)

        aggregate.apply_existing_event(Added.new(aggregate_id: id))
        expect(aggregate.state).to eq(:added)
        expect(aggregate.applied_events).to eq([])

        aggregate.apply_existing_event(Deleted.new(aggregate_id: id))
        expect(aggregate.state).to eq(:deleted)
        expect(aggregate.applied_events).to eq([])
      end

      it "raises an error for unknown events" do
        stub_const("UnknownEvent", Class.new(Event))
        expect do
          aggregate.apply_existing_event(UnknownEvent.new(aggregate_id: id))
        end.to raise_error(AggregateRoot::UnknownEventError, "ExampleAggregate doesn't have a binding for 'UnknownEvent'")
      end
    end
  end
end
