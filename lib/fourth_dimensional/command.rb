require "active_model"

module FourthDimensional
  # == FourthDimensional::Command
  #
  # Commands are the input to create events. They provide an early validation
  # step to ensuring the data format is correct before validating the current
  # state of the system.
  #
  #   class AddPost < FourthDimensional::Command
  #     attributes :title, :body, :published
  #     validates_presence_of :title, :body
  #   end
  #
  #   AddPost.new # => raises ArgumentError.new("missing keywords: aggregate_id, :title, :body, :published)
  #   command = AddPost.new(aggregate_id: '1-2-3', title: 'post-title', body: 'post-body', published: false)
  #   command.valid? # => true
  #   command.aggregate_id # => '1-2-3'
  #   command.title # => 'post-title'
  #   command.body # => 'post-body'
  #   command.published # => false
  #
  #   command.to_h # => {'title' => 'post-title', 'body' => 'post-body', 'published' => false}
  class Command
    include ActiveModel::Validations

    # The aggregate the command is acting on
    attr_reader :aggregate_id

    def initialize(aggregate_id:)
      @aggregate_id = aggregate_id
    end

    def to_h
      {}
    end

    # Defines an initializer with required keyword arguments, readonly only
    # attributes and +to_h+ to access all defined attributes
    #
    #   class AddPost < FourthDimensional::Command
    #     attributes :title, :body, :published
    #   end
    def self.attributes(*attributes)
      attr_reader *attributes

      method_arguments = attributes.map { |arg| "#{arg}:" }.join(', ')
      method_assignments = attributes.map { |arg| "@#{arg} = #{arg}" }.join(';')
      method_attrs_to_hash = attributes.map { |arg| "'#{arg}' => #{arg}" }.join(',')

      class_eval <<~CODE
        def initialize(aggregate_id:, #{method_arguments})
          @aggregate_id = aggregate_id
          #{method_assignments}
        end

        def to_h
          {#{method_attrs_to_hash}}
        end
      CODE
    end
  end
end
