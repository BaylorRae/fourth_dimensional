require "spec_helper"

module FourthDimensional
  describe Command do
    let(:aggregate_id) { double(:aggregate_id) }

    before { stub_const('ExampleCommand', Class.new(Command)) }

    context "attributes" do
      context "aggregate_id" do
        it "requires an aggregate_id with no attributes" do
          expect do
            command = ExampleCommand.new
          end.to raise_error(ArgumentError, 'missing keyword: aggregate_id')

          command = ExampleCommand.new(aggregate_id: aggregate_id)
          expect(command.aggregate_id).to eq(aggregate_id)

          expect do
            command.aggregate_id = 'something-different'
          end.to raise_error(NoMethodError)
        end

        it "requires all attributes as keyword arguments" do
          ExampleCommand.class_eval do
            attributes :name, :email
          end

          expect do
            ExampleCommand.new
          end.to raise_error(ArgumentError, 'missing keywords: aggregate_id, name, email')

          command = ExampleCommand.new(aggregate_id: aggregate_id,
                                       name: 'bob',
                                       email: 'bob@example.com')
          expect(command.aggregate_id).to eq(aggregate_id)

          expect do
            command.aggregate_id = 'something-different'
          end.to raise_error(NoMethodError)

          expect do
            command.name = 'something-new'
          end.to raise_error(NoMethodError)

          expect do
            command.email = 'something-different-and-new'
          end.to raise_error(NoMethodError)
        end
      end

      it "has attributes" do
        ExampleCommand.class_eval do
          attributes :name
        end

        command = ExampleCommand.new(aggregate_id: aggregate_id,
                                     name: 'bob')
        expect(command.name).to eq('bob')
      end

      it "makes attributes accessible in a hash" do
        ExampleCommand.class_eval do
          attributes :name, :email
          attr_accessor :age
        end

        command = ExampleCommand.new(aggregate_id: aggregate_id,
                                     name: 'bob',
                                     email: 'bob@example.com')
        command.age = 35
        expect(command.to_h).to eq({
          'name' => 'bob',
          'email' => 'bob@example.com'
        })
      end
    end

    context "validations" do
      it "validates known attributes" do
        ExampleCommand.class_eval do
          attributes :name, :email
          validates_presence_of :name, :email
        end

        command = ExampleCommand.new(aggregate_id: nil,
                                     name: nil,
                                     email: nil)
        command.valid?
        expect(command.errors.full_messages).to eq([
          "Name can't be blank",
          "Email can't be blank"
        ])
      end
    end
  end
end
