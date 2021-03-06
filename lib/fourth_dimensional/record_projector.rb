require 'active_support/core_ext/class/attribute'

module FourthDimensional
  # == FourthDimensional::RecordProjector
  #
  #   class PostProjector < FourthDimensional::RecordProjector
  #     self.record_class = 'Post'
  #
  #     on TitleChanged do |event|
  #       record.title = event.title
  #     end
  #   end
  class RecordProjector
    include Eventable

    # Record class this projector creates
    class_attribute :record_class

    # The current instance of the projected record
    attr_reader :record

    def initialize(aggregate_id:)
      @record = record_class.constantize.find_or_initialize_by(id: aggregate_id)
    end

    # Invokes the event binding.
    #
    #   post_projector.apply_event(TitleChanged.new(aggregate_id: aggregate_id,
    #                                               data: {title: 'new-post-title'}))
    def apply_event(event)
      callback = self.class.event_bindings[event.class]
      return if callback.nil?
      instance_exec(event, &callback)
    end

    # Saves the record at it's current state.
    #
    #   post_projector.save
    def save
      record.save
    end

    # Applies multiple events and saves at the end.
    #
    #   projector.record.persisted? # => false
    #   projector.call(event1, event2)
    #   projector.record.persisted? # => true
    def call(*events)
      events.flatten.map(&method(:apply_event))
      save
    end

    # Bulk apply and save events to multiple aggregates.
    def self.call(*events)
      events.flatten.group_by(&:aggregate_id).each do |aggregate_id, events|
        new(aggregate_id: aggregate_id).call(events)
      end
    end
  end
end
