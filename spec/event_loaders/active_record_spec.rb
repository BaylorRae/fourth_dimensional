require "spec_helper"

module FourthDimensional
  module EventLoaders
    describe ActiveRecord do
      before do
        ::ActiveRecord::Base.establish_connection(
          adapter: :sqlite3,
          dbfile: ':memory:',
          database: ':memory:'
        )

        ::ActiveRecord::Base.connection.execute(<<~SQL
create table commands (
  id integer primary key autoincrement,
  aggregate_id uuid not null,
  command_type text not null,
  data text,
  created_at datetime,
  updated_at datetime
)
        SQL
        )

        ::ActiveRecord::Base.connection.execute(<<~SQL
create table events (
  id integer primary key autoincrement,
  uuid uuid not null,
  aggregate_id uuid not null,
  event_type text not null,
  data text,
  metadata text,
  version integer,
  created_at datetime,
  updated_at datetime
);
        SQL
        )
      end

      after do
        ::ActiveRecord::Base.clear_all_connections!
      end

      context "for_aggregate"

      context "save_commands_and_events" do
        before do
          stub_const("ExampleCommand", Class.new(Command))
          stub_const("ModuleName::Command", Class.new(Command))

          ExampleCommand.class_eval do
            attributes :string, :number, :float, :boolean
          end

          ModuleName::Command.class_eval do
            attributes :data
          end
        end

        it "saves the command attributes" do
          aggregate_id = SecureRandom.uuid
          now = Time.now

          command = ExampleCommand.new(
            aggregate_id: aggregate_id,
            string: 'example-string',
            number: 123,
            float: 123.45,
            boolean: true
          )

          command2 = ModuleName::Command.new(
            aggregate_id: aggregate_id,
            data: {
              complicated: true
            }
          )

          event_loader = ActiveRecord.new
          event_loader.save_commands_and_events(
            commands: [command, command2],
            events: []
          )
          
          expect(ActiveRecord::Command.count).to eq(2)

          actual_command_1 = ActiveRecord::Command.first
          expect(actual_command_1.aggregate_id).to eq(aggregate_id)
          expect(actual_command_1.command_type).to eq('example_command')
          expect(actual_command_1.data).to eq({
            'string' => 'example-string',
            'number' => 123,
            'float' => 123.45,
            'boolean' => true
          })

          actual_command_2 = ActiveRecord::Command.last
          expect(actual_command_2.aggregate_id).to eq(aggregate_id)
          expect(actual_command_2.command_type).to eq('module_name/command')
          expect(actual_command_2.data).to eq({
            'data' => {'complicated' => true}
          })
        end

        it "saves events" do
          stub_const("Event1", Class.new(Event))
          stub_const("Event2", Class.new(Event))
          stub_const("AnotherModule::Event3", Class.new(Event))

          aggregate_id_1 = SecureRandom.uuid
          aggregate_id_2 = SecureRandom.uuid

          event1 = Event1.new(aggregate_id: aggregate_id_1,
                              data: {string: 'string'},
                              metadata: {integer: 45})

          event2 = Event2.new(aggregate_id: aggregate_id_2,
                              data: {float: 4.2},
                              metadata: {boolean: false})

          event3 = AnotherModule::Event3.new(aggregate_id: aggregate_id_1,
                              data: {},
                              metadata: {})

          event_loader = ActiveRecord.new
          event_loader.save_commands_and_events(
            commands: [],
            events: [event1, event2, event3]
          )

          expect(ActiveRecord::Event.count).to eq(3)

          actual_event_1 = ActiveRecord::Event.find(1)
          expect(actual_event_1.aggregate_id).to eq(aggregate_id_1)
          expect(actual_event_1.version).to eq(1)
          expect(actual_event_1.event_type).to eq('event1')
          expect(actual_event_1.data).to eq({'string' => 'string'})
          expect(actual_event_1.metadata).to eq({'integer' => 45})

          actual_event_2 = ActiveRecord::Event.find(2)
          expect(actual_event_2.aggregate_id).to eq(aggregate_id_2)
          expect(actual_event_2.version).to eq(1)
          expect(actual_event_2.event_type).to eq('event2')
          expect(actual_event_2.data).to eq({'float' => 4.2})
          expect(actual_event_2.metadata).to eq({'boolean' => false})

          actual_event_3 = ActiveRecord::Event.find(3)
          expect(actual_event_3.aggregate_id).to eq(aggregate_id_1)
          expect(actual_event_3.version).to eq(2)
          expect(actual_event_3.event_type).to eq('another_module/event3')
          expect(actual_event_3.data).to eq({})
          expect(actual_event_3.metadata).to eq({})
        end

        it "continues incrementing the version of an aggregate" do
          stub_const("Event1", Class.new(Event))

          aggregate_id = SecureRandom.uuid

          ActiveRecord::Event.create!([
            {uuid: SecureRandom.uuid, event_type: 'event_type',
             aggregate_id: SecureRandom.uuid, version: 5},

            {uuid: SecureRandom.uuid, event_type: 'event_type',
             aggregate_id: aggregate_id, version: 1},
            {uuid: SecureRandom.uuid, event_type: 'event_type',
             aggregate_id: aggregate_id, version: 3},
            {uuid: SecureRandom.uuid, event_type: 'event_type',
             aggregate_id: aggregate_id, version: 4},
            {uuid: SecureRandom.uuid, event_type: 'event_type',
             aggregate_id: aggregate_id, version: 2},

            {uuid: SecureRandom.uuid, event_type: 'event_type',
             aggregate_id: SecureRandom.uuid, version: 6}
          ])

          event = Event1.new(aggregate_id: aggregate_id)

          event_loader = ActiveRecord.new
          event_loader.save_commands_and_events(
            commands: [],
            events: [event]
          )

          actual_event = ActiveRecord::Event.last
          expect(actual_event.aggregate_id).to eq(aggregate_id)
          expect(actual_event.version).to eq(5)
          expect(actual_event.event_type).to eq('event1')
          expect(actual_event.data).to eq({})
          expect(actual_event.metadata).to eq({})
        end
      end
    end
  end
end
