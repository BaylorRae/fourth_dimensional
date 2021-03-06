module FourthDimensional
  # == FourthDimensional::AggregateRoot
  #
  # An aggregate root is an object whose entire state is built by applying
  # events in sequential order.
  #
  # Often you will see an aggregate root providing a method to create the event
  # followed by a event binding to apply the changes to the current object.
  #
  #   class Post < FourthDimensional::AggregateRoot
  #     attr_reader :state, :title
  #
  #     def initialize(*args)
  #       super
  #
  #       @state = :draft
  #     end
  #
  #     def add(title:)
  #       apply PostAdded, data: { title: title }
  #     end
  #
  #     def delete
  #       apply PostDeleted
  #     end
  #
  #     on PostAdded do |event|
  #       @state = :added
  #       @title = event.data.fetch('title')
  #     end
  #
  #     on PostDeleted do |event|
  #       @state = :deleted
  #     end
  #   end
  #
  #   aggregate = Post.new(id: SecureRandom.uuid)
  #   aggregate.state # => :draft
  #   aggregate.title # => nil
  #
  #   aggregate.add(title: 'post-title')
  #   aggregate.state # => :added
  #   aggregate.title # => 'post-title'
  #
  #   aggregate.delete
  #   aggregate.state # => :deleted
  class AggregateRoot
    include Eventable

    UnknownEventError = Class.new(Error)

    # aggregate id
    attr_reader :id

    # array of events applied
    attr_reader :applied_events

    # current version
    attr_reader :version

    # Initializes an aggregate with an id
    def initialize(id:)
      @id = id

      @applied_events = []
      @version = 1
    end

    # Applies an event to the aggregate when a callback is bound. **+args+ are
    # merged with the +id+ of the aggregate.
    #
    # Callbacks are invoked within the instance of the aggregate root.
    def apply(event_class, **args)
      event = event_class.new(args.merge(aggregate_id: id))
      apply_existing_event(event)
      applied_events << event
    end

    # Calls the event binding without persisting the event being applied. Used
    # when loading an aggregate from an existing store.
    #
    #   post.apply_existing_event(title_updated_event)
    def apply_existing_event(event)
      callback = self.class.event_bindings[event.class]

      if callback.nil?
        raise UnknownEventError.new("#{self.class.name} doesn't have a binding for '#{event.class}'")
      end

      instance_exec(event, &callback)
      @version = next_version
    end

    private

    def next_version
      version + 1
    end
  end
end
