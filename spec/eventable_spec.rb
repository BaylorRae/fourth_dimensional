require "spec_helper"

module FourthDimensional
  describe Eventable do
    context "on" do
      before do
        stub_const("Event1", Class.new(Event))
        stub_const("Event2", Class.new(Event))
        stub_const("ExampleWithEvents", Class.new)
      end

      it "registers bound events" do
        event1_callback = -> {}
        event2_callback = -> {}

        ExampleWithEvents.class_eval do
          include Eventable

          on Event1, &event1_callback
          on Event2, &event2_callback
        end

        expect(ExampleWithEvents.event_bindings).to eq({
          Event1 => event1_callback,
          Event2 => event2_callback
        })

        expect(ExampleWithEvents.events).to eq([Event1, Event2])
      end

      it "doesn't allow duplicate events" do
        event1_callback = -> {}
        event2_callback = -> {}

        expect do
          ExampleWithEvents.class_eval do
            include Eventable

            on Event1, &event1_callback
            on Event1, &event2_callback
          end
        end.to raise_error(KeyError, "Event1 is already bound on ExampleWithEvents")
      end
    end
  end
end
