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
  end
end
