require "spec_helper"

module FourthDimensional
  describe Repository do
    context "events_for_aggregate" do
      it "delegates loading events" do
        aggregate_id = double(:aggregate_id)
        events = double(:events)

        event_loader = double(:event_loader)
        allow(event_loader).to receive(:for_aggregate).with(aggregate_id) { events }

        repository = Repository.new(event_loader: event_loader)
        expect(repository.events_for_aggregate(aggregate_id)).to eq(events)
      end
    end

    context "load_aggregate" do
      let(:aggregate_id) { double(:aggregate_id) }

      before do
        stub_const("ExampleAggregate", Class.new(AggregateRoot))
        stub_const("UpdateTitle", Class.new(Event))
        stub_const("Publish", Class.new(Event))

        ExampleAggregate.class_eval do
          attr_reader :title, :published

          def initialize(*args)
            super

            @published = false
          end

          on UpdateTitle do |event|
            @title = event.data.fetch('title')
          end

          on Publish do |event|
            @published = event.data.fetch('published')
          end
        end
      end

      it "loads an aggregate and applies events" do
        events = [
          UpdateTitle.new(aggregate_id: aggregate_id, data: {title: 'title-v1'}),
          Publish.new(aggregate_id: aggregate_id, data: {published: false}),
          UpdateTitle.new(aggregate_id: aggregate_id, data: {title: 'title-v2'}),
          Publish.new(aggregate_id: aggregate_id, data: {published: true})
        ]

        event_loader = double(:event_loader)
        allow(event_loader).to receive(:for_aggregate).with(aggregate_id) { events }

        repository = Repository.new(event_loader: event_loader)
        aggregate = repository.load_aggregate(ExampleAggregate, aggregate_id)
        expect(aggregate.title).to eq('title-v2')
        expect(aggregate.published).to eq(true)
        expect(aggregate.applied_events).to eq([])
      end

      it "loads without any events" do
        event_loader = double(:event_loader)
        allow(event_loader).to receive(:for_aggregate).with(aggregate_id) { [] }

        repository = Repository.new(event_loader: event_loader)
        aggregate = repository.load_aggregate(ExampleAggregate, aggregate_id)
        expect(aggregate.title).to be_nil
        expect(aggregate.published).to eq(false)
        expect(aggregate.applied_events).to eq([])
      end
    end

    context "save_command_and_events" do
      let(:event_loader) { double(:event_loader) }
      let(:repository) { Repository.new(event_loader: event_loader) }

      let(:command1) { double(:command1) }
      let(:command2) { double(:command2) }

      let(:events1) { [double(:events1), double(:events1_2)] }
      let(:events2) { [double(:events2)] }

      it "returns events saved" do
        repository.save_command_and_events(CommandHandler::CommandAndEvents.new(
          command: command1,
          events: events1
        ))

        repository.save_command_and_events(CommandHandler::CommandAndEvents.new(
          command: command2,
          events: events2
        ))

        expect(repository.called_commands).to eq([command1, command2])
        expect(repository.applied_events).to eq([*events1, *events2])
      end
    end
  end
end
