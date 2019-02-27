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

    # persisted event attributes
    attr_reader :id, :version, :created_at, :updated_at

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
    #                       version: 1,
    #                       data: { one: 1 },
    #                       metadata: { two: 2 })
    #   event.version # => 1
    #   event.data # => { 'one' => 1 }
    #   event.metadata # => { 'two' => 2 }
    def initialize(aggregate_id:,
                   id: nil,
                   version: nil,
                   created_at: nil,
                   updated_at: nil,
                   data: nil,
                   metadata: nil)
      @aggregate_id = aggregate_id
      @id = id
      @version = version
      @created_at = created_at
      @updated_at = updated_at
      @data = (data || {}).transform_keys(&:to_s)
      @metadata = (metadata || {}).transform_keys(&:to_s)
    end
  end
end
