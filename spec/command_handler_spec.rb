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
      let(:aggregate_id) { double(:aggregate_id) }
      let(:command) { double(:command, aggregate_id: aggregate_id) }
      let(:events) { double(:events) }

      let(:handler) { ExampleCommandHandler.new(repository: repository) }

      let(:loaded_aggregate) { double(:example_aggregate, applied_events: events) }

      before do
        stub_const("ExampleAggregate", Class.new(AggregateRoot))
        stub_const("ExampleCommandHandler", Class.new(CommandHandler))

        allow(repository).to receive(:load_aggregate)
          .with(ExampleAggregate, aggregate_id)
          .and_return(loaded_aggregate)
      end

      it "loads an aggregate with the command's aggregate id" do
        expect(repository).to receive(:save_command_and_events)
          .with(CommandHandler::CommandAndEvents.new(
            command: command,
            events: events
          ))

        aggregate = nil
        handler.with_aggregate(ExampleAggregate, command) do |x|
          aggregate = x
        end
        expect(aggregate).to eq(loaded_aggregate)
      end
    end

    context "save" do
      it "saves the command and aggregate events" do
        stub_const("ExampleCommandHandler", Class.new(CommandHandler))
        handler = ExampleCommandHandler.new(repository: repository)

        command = double(:command)
        events = double(:events)
        aggregate = double(:aggregate, applied_events: events)

        expect(repository).to receive(:save_command_and_events)
          .with(CommandHandler::CommandAndEvents.new(
            command: command,
            events: events
          ))

        handler.save(command, aggregate)
      end
    end
  end
end
