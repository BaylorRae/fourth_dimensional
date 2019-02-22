require "active_support/core_ext/hash/keys"

module FourthDimensional
  # == FourthDimensional::Event
  #
  # Events act as a log primarily focused around an aggregate. When persisted it
  # will use the underscored version of the class name as the +event_type+.
  #
  #   module Posts
  #     PostAdded = Class.new(FourthDimensional::Event)
  #   end
  #
  # It is recommended practice to add delegating methods to the attributes
  # within +data+. These aliases will make it easier to see what's being stored
  # from the codebase.
  #
  #   module Posts
  #     class PostAdded < FourthDimensional::Event
  #       def title
  #         data.fetch('title')
  #       end
  #
  #       def body
  #         data.fetch('body')
  #       end
  #     end
  #   end
  class Event
    attr_reader :aggregate_id

    # hash of data with stringified keys
    attr_reader :data, :metadata

    # Initializes an event with the required +aggregate_id+ and optional +data+
    # and +metadata+.
    #
    #   event = MyEvent.new(aggregate_id: '1-2-3')
    #   event.aggregate_id # => '1-2-3'
    #   event.data # => {}
    #   event.metadata # => {}
    #
    # +data+ and +metadata+ should be hashes and the keys will transformed  into
    # strings to accommodate deserializing the values from json.
    #
    #   event = MyEvent.new(aggregate_id: '1-2-3',
    #                       data: { one: 1 },
    #                       metadata: { two: 2 })
    #   event.data # => { 'one' => 1 }
    #   event.metadata # => { 'two' => 2 }
    def initialize(aggregate_id:, data: nil, metadata: nil)
      @aggregate_id = aggregate_id
      @data = (data || {}).transform_keys(&:to_s)
      @metadata = (metadata || {}).transform_keys(&:to_s)
    end
  end
end
