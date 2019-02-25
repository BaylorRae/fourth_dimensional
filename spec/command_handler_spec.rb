require "spec_helper"

module FourthDimensional
  describe CommandHandler do
    let(:repository) { double(:repository) }

    context "call" do
      it "invokes bound commands" do
        stub_const("Command1", Class.new(Command))
        stub_const("Command2", Class.new(Command))
        stub_const("ExampleCommandHandler", Class.new(CommandHandler))

        command = Command1.new(aggregate_id: '1-2-3')

        command1_callback = double(:command1_callback)
        expect(command1_callback).to receive(:call).with(command)

        ExampleCommandHandler.class_eval do
          on Command1 do |command|
            command1_callback.call(command)
          end

          on Command2 do |command|
            raise StandardError.new("shouldn't have been called")
          end
        end

        handler = ExampleCommandHandler.new(repository: repository)
        handler.call(command)
      end

      it "allows unknown commands" do
        stub_const("Command1", Class.new(Command))
        stub_const("ExampleCommandHandler", Class.new(CommandHandler))

        command = Command1.new(aggregate_id: '1-2-3')
        handler = ExampleCommandHandler.new(repository: repository)
        handler.call(command)
      end
    end

    context "with_aggregate" do
      it "loads an aggregate with the command's aggregate id" do
        stub_const("ExampleAggregate", Class.new(AggregateRoot))
        stub_const("Command1", Class.new(Command))
        stub_const("ExampleCommandHandler", Class.new(CommandHandler))

        aggregate_id = double(:aggregate_id)
        command = Command1.new(aggregate_id: aggregate_id)
        handler = ExampleCommandHandler.new(repository: repository)

        loaded_aggregate = double(:example_aggregate)
        allow(loaded_aggregate).to receive(:applied_events) { [] }

        allow(repository).to receive(:load_aggregate)
          .with(ExampleAggregate, aggregate_id)
          .and_return(loaded_aggregate)

        aggregate = nil
        handler.with_aggregate(ExampleAggregate, command) do |x|
          aggregate = x
        end
        expect(aggregate).to eq(loaded_aggregate)
      end
    end

    context "tracked_command_and_events" do
      let(:aggregate_id) { double(:aggregate_id) }
      let(:command) { Command1.new(aggregate_id: aggregate_id) }

      before do
        stub_const("ExampleAggregate", Class.new(AggregateRoot))
        stub_const("ExampleAggregate2", Class.new(AggregateRoot))

        stub_const("ExampleEvent1", Class.new(Event))
        stub_const("ExampleEvent2", Class.new(Event))

        stub_const("Command1", Class.new(Command))
        stub_const("ExampleCommandHandler", Class.new(CommandHandler))

        ExampleAggregate.class_eval do
          def example_event1
            apply ExampleEvent1
          end

          def example_event2
            apply ExampleEvent2
          end

          on ExampleEvent1 do
          end

          on ExampleEvent2 do
          end
        end

        ExampleAggregate2.class_eval do
          def example_event1
            apply ExampleEvent1
          end

          def example_event2
            apply ExampleEvent2
          end

          on ExampleEvent1 do
          end

          on ExampleEvent2 do
          end
        end

        ExampleCommandHandler.class_eval do
          on Command1 do |command|
            with_aggregate(ExampleAggregate, command) do |aggregate|
              aggregate.example_event1
              aggregate.example_event2
            end

            with_aggregate(ExampleAggregate2, command) do |aggregate|
              aggregate.example_event1
              aggregate.example_event2
            end
          end
        end
      end

      it "tracks the command and events applied to multiple aggregates" do
        allow(repository).to receive(:load_aggregate)
          .with(ExampleAggregate, aggregate_id)
          .and_return(ExampleAggregate.new(id: aggregate_id))

        allow(repository).to receive(:load_aggregate)
          .with(ExampleAggregate2, aggregate_id)
          .and_return(ExampleAggregate2.new(id: aggregate_id))

        handler = ExampleCommandHandler.new(repository: repository)
        handler.call(command)

        command_and_events = handler.tracked_command_and_events

        expect(command_and_events.command).to eq(command)

        expect(command_and_events.events.length).to eq(4)

        expect(command_and_events.events.map(&:class)).to eq([
          ExampleEvent1, ExampleEvent2,
          ExampleEvent1, ExampleEvent2
        ])

        expect(command_and_events.events.map(&:aggregate_id)).to eq([
          aggregate_id, aggregate_id,
          aggregate_id, aggregate_id
        ])
      end
    end
  end
end
