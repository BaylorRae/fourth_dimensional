module FourthDimensional
  # == Eventable
  #
  # Provides an api for registering event bindings.
  #
  #   class CantHandleTheTruth
  #     include FourthDimensional::Eventable
  #
  #     on TheTruth do |event|
  #       raise RunTimeError.new("an error occured that can not be rescued")
  #     end
  #   end
  module Eventable
    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      # Binds an event to the aggregate. Raises a +KeyError+ if the event has
      # already been bound.
      #
      #   Post.on(PostAdded, -> (event) {})
      #   Post.on(PostAdded, -> (event) {}) # => raises KeyError
      def on(klass, &block)
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
      def events
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
      def event_bindings
        @event_bindings ||= {}
      end
    end
  end
end
