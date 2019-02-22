require "spec_helper"

module FourthDimensional
  describe AggregateRoot do
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

    context "on" do
      before do
        stub_const("Event1", Class.new(Event))
        stub_const("Event2", Class.new(Event))
        stub_const("ExampleAggregate", Class.new(AggregateRoot))
      end

      it "registers bound events" do
        event1_callback = -> {}
        event2_callback = -> {}

        ExampleAggregate.class_eval do
          on Event1, &event1_callback
          on Event2, &event2_callback
        end

        expect(ExampleAggregate.event_bindings).to eq({
          Event1 => event1_callback,
          Event2 => event2_callback
        })

        expect(ExampleAggregate.events).to eq([Event1, Event2])
      end

      it "doesn't allow duplicate events" do
        event1_callback = -> {}
        event2_callback = -> {}

        expect do
          ExampleAggregate.class_eval do
            on Event1, &event1_callback
            on Event1, &event2_callback
          end
        end.to raise_error(KeyError, "Event1 is already bound on ExampleAggregate")
      end
    end

    context "apply" do
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

      it "ignores unknown events" do
        stub_const("UnknownEvent", Class.new(Event))
        aggregate.apply(UnknownEvent)
        expect(aggregate.state).to eq(:initial)
        expect(aggregate.applied_events).to eq([])
      end
    end
  end
end
