require "spec_helper"
require "active_record_helper"

module FourthDimensional
  module EventLoaders
    describe ActiveRecord do
      context "for_aggregate" do
        it "deserializes an event to its original class" do
          aggregate_id = SecureRandom.uuid
          stub_const("My::Deep::Event", Class.new(Event))
          stub_const("TopLevelEvent", Class.new(Event))

          ActiveRecord::Event.create!([
            {
              uuid: SecureRandom.uuid,
              aggregate_id: aggregate_id,
              version: 2,
              event_type: "my/deep/event",
              data: {
                string: 'example-string',
                float: 13.37
              },
              metadata: {
                aggregate_id: aggregate_id
              }
            },
            {
              uuid: SecureRandom.uuid,
              aggregate_id: SecureRandom.uuid,
              version: 1,
              event_type: "my/deep/event",
              data: {},
              metadata: {}
            },
            {
              uuid: SecureRandom.uuid,
              aggregate_id: aggregate_id,
              version: 1,
              event_type: "top_level_event"
            }
          ])

          event_loader = ActiveRecord.new
          events = event_loader.for_aggregate(aggregate_id)

          expect(events.length).to eq(2)

          event = events.first
          expect(event).to be_instance_of(TopLevelEvent)
          expect(event.version).to eq(1)
          expect(event.aggregate_id).to eq(aggregate_id)
          expect(event.data).to eq({})
          expect(event.metadata).to eq({})

          event = events.second
          expect(event).to be_instance_of(My::Deep::Event)
          expect(event.version).to eq(2)
          expect(event.aggregate_id).to eq(aggregate_id)
          expect(event.data).to eq({
            'string' => 'example-string',
            'float' => 13.37
          })
          expect(event.metadata).to eq({
            'aggregate_id' => aggregate_id
          })
        end
      end

      context "deserialize_event" do
        it "creates an instance of the original event" do
          stub_const("ExampleEvent", Class.new(Event))

          aggregate_id = double(:aggregate_id)
          version = double(:version, to_i: 1)
          data = double(:data)
          metadata = double(:metadata)
          created_at = double(:created_at)
          updated_at = double(:updated_at)

          event = ActiveRecord::Event.new(aggregate_id: aggregate_id,
                                          id: 1,
                                          version: version,
                                          event_type: 'example_event',
                                          data: data,
                                          metadata: metadata,
                                          created_at: created_at,
                                          updated_at: updated_at)

          event_loader = ActiveRecord.new

          event = event_loader.deserialize_event(event)
          expect(event).to be_instance_of(ExampleEvent)
          expect(event.aggregate_id).to eq(aggregate_id)
          expect(event.id).to eq(1)
          expect(event.version).to eq(version.to_i)
          expect(event.data).to eq(JSON.parse(data.to_json))
          expect(event.metadata).to eq(JSON.parse(metadata.to_json))
          expect(event.created_at).to eq(created_at)
          expect(event.updated_at).to eq(updated_at)
        end
      end

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

        it "returns deserialized events" do
          stub_const("Event1", Class.new(Event))

          aggregate_id = SecureRandom.uuid

          event = Event1.new(aggregate_id: aggregate_id)

          event_loader = ActiveRecord.new
          created_events = event_loader.save_commands_and_events(
            commands: [],
            events: [event]
          )

          expect(created_events.length).to eq(1)
          event = created_events.first

          expect(event).to be_instance_of(Event1)
          expect(event.aggregate_id).to eq(aggregate_id)
          expect(event.id).to eq(1)
          expect(event.version).to eq(1)
          expect(event.created_at).to_not be_nil
          expect(event.updated_at).to_not be_nil
        end
      end
    end
  end
end
