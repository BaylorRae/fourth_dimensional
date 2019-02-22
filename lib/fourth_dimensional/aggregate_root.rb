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
    # aggregate id
    attr_reader :id

    # array of events applied
    attr_reader :applied_events

    # Initializes an aggregate with an id
    def initialize(id:)
      @id = id

      @applied_events = []
    end

    # Applies an event to the aggregate when a callback is bound. **+args+ are
    # merged with the +id+ of the aggregate.
    #
    # Callbacks are invoked within the instance of the aggregate root.
    def apply(event_class, **args)
      callback = self.class.event_bindings[event_class]
      return if callback.nil?
      event = event_class.new(args.merge(aggregate_id: id))
      instance_exec(event, &callback)
      applied_events << event
    end

    # Binds an event to the aggregate. Raises a +KeyError+ if the event has
    # already been bound.
    #
    #   Post.on(PostAdded, -> (event) {})
    #   Post.on(PostAdded, -> (event) {}) # => raises KeyError
    def self.on(klass, &block)
      if event_bindings.has_key?(klass)
        raise KeyError.new("#{klass.name} is already bound on #{self.name}") 
      end

      event_bindings[klass] = block
    end

    # Returns an array of class names for the bound events.
    #
    #   Post.on(PostAdded, -> (event) {})
    #   Post.on(PostDeleted, -> (event) {})
    #
    #   Post.events # => [PostAdded, PostDeleted]
    def self.events
      event_bindings.keys
    end

    # Returns a hash of event classes and the callback.
    #
    #   Post.on(PostAdded, -> (event) {})
    #   Post.on(PostDeleted, -> (event) {})
    #
    #   Post.event_bindings # => {
    #     PostAdded => Proc,
    #     PostDeleted => Proc
    #   }
    def self.event_bindings
      @event_bindings ||= {}
    end
  end
end
