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

  context "execute_commands" do
    let(:aggregate_id) { double(:aggregate_id) }

    before do
      stub_const("Command1", Class.new(FourthDimensional::Command))
      stub_const("Command2", Class.new(FourthDimensional::Command))
      stub_const("Command3", Class.new(FourthDimensional::Command))
      stub_const("CommandHandler1", Class.new(FourthDimensional::CommandHandler))
      stub_const("CommandHandler2", Class.new(FourthDimensional::CommandHandler))

      FourthDimensional.config.event_loader = spy(:event_loader)
      FourthDimensional.config.command_handlers = [
        CommandHandler1,
        CommandHandler2,
      ]
    end

    after do
      FourthDimensional.config.command_handlers = []
      FourthDimensional.config.event_handlers = []
      FourthDimensional.config.event_loader = nil
    end

    it "calls a command handler" do
      command = Command1.new(aggregate_id: aggregate_id)
      command_callback = double(:command_callback)

      CommandHandler1.class_eval do
        on Command1 do |command|
          command_callback.call(command)
        end
      end

      expect(command_callback).to receive(:call).with(command)
      FourthDimensional.execute_commands(command)
    end

    it "calls multiple command handlers" do
      command1 = Command1.new(aggregate_id: aggregate_id)
      command2 = Command2.new(aggregate_id: aggregate_id)
      command3 = Command3.new(aggregate_id: aggregate_id)

      command1_callback = double(:command1_callback)
      command2_callback = double(:command2_callback)
      command3_callback = double(:command3_callback)

      CommandHandler1.class_eval do
        on Command1 do |command|
          command1_callback.call(command)
        end

        on Command2 do |command|
          command2_callback.call(command)
        end
      end

      CommandHandler2.class_eval do
        on Command3 do |command|
          command3_callback.call(command)
        end
      end

      expect(command1_callback).to receive(:call).with(command1)
      expect(command2_callback).to receive(:call).with(command2)
      expect(command3_callback).to receive(:call).with(command3)
      FourthDimensional.execute_commands(command1, command2, command3)

      expect(command1_callback).to receive(:call).with(command1)
      expect(command2_callback).to receive(:call).with(command2)
      expect(command3_callback).to receive(:call).with(command3)
      FourthDimensional.execute_commands([command1, command2, command3])
    end

    it "saves commands and events" do
      event = double(:event)
      aggregate = double(:aggregate, applied_events: [event])

      CommandHandler1.class_eval do
        on Command1 do |x_command|
          save(x_command, aggregate)
        end
      end

      command = Command1.new(aggregate_id: nil)

      event_loader = double(:event_loader)
      expect(event_loader).to receive(:save_commands_and_events).with(
        commands: [command],
        events: [event]
      )

      FourthDimensional.config.event_loader = event_loader
      FourthDimensional.execute_commands(command)
    end
  end
end
