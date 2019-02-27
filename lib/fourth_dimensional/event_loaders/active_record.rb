require 'active_record'

module FourthDimensional
  module EventLoaders
    # == FourthDimensional::EventLoaders::ActiveRecord
    #
    #   FourthDimensional.configure do |config|
    #     config.event_loader = FourthDimensional::EventLoaders::ActiveRecord.new
    #   end
    class ActiveRecord
      # Loads events by +aggregate_id+ and deserializes them.
      #
      #   FourthDimensional.config.event_loader.for_aggregate(aggregate_id)
      def for_aggregate(aggregate_id)
        Event.where(aggregate_id: aggregate_id)
          .order(:version)
          .map(&method(:deserialize_event))
      end

      # Deserializes a single event.
      def deserialize_event(event)
        event.event_type.camelize.constantize.new(aggregate_id: event.aggregate_id,
                                                  version: event.version,
                                                  data: event.data,
                                                  metadata: event.metadata,
                                                  created_at: event.created_at,
                                                  updated_at: event.updated_at)
      end

      # Saves commands and events in active record compatible database.
      def save_commands_and_events(commands:, events:)
        FourthDimensionalRecord.transaction do
          create_commands!(commands)
          create_events!(events)
        end
      end

      class FourthDimensionalRecord < ::ActiveRecord::Base # :nodoc:
        self.abstract_class = true
      end

      class Command < FourthDimensionalRecord # :nodoc:
        self.table_name = FourthDimensional.config.table_prefix + 'commands'

        serialize :data, JSON
      end

      class Event < FourthDimensionalRecord # :nodoc:
        self.table_name = FourthDimensional.config.table_prefix + 'events'

        serialize :data, JSON
        serialize :metadata, JSON
      end

      private

      def create_commands!(commands)
        commands.each do |command|
          Command.create!(aggregate_id: command.aggregate_id,
                          command_type: command.class.name.underscore,
                          data: command.to_h)
        end
      end

      def create_events!(events)
        versions = aggregate_versions
        events.each do |event|
          version = versions[event.aggregate_id] += 1
          Event.create!(uuid: SecureRandom.uuid,
                        aggregate_id: event.aggregate_id,
                        version: version,
                        event_type: event.class.name.underscore,
                        data: event.data,
                        metadata: event.metadata)
        end
      end

      def aggregate_versions
        Hash.new { |hash, key| hash[key] = 0 }
          .merge(Event.group(:aggregate_id).maximum(:version).to_h)
      end
    end
  end
end
