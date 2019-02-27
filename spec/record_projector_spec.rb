require "spec_helper"
require "active_record_helper"

module FourthDimensional
  describe RecordProjector do
    let(:aggregate_id) { SecureRandom.uuid }

    before do
      ::ActiveRecord::Base.connection.execute(<<~SQL
create table posts (
  id uuid primary key,
  title varchar(100),
  published boolean,
  created_at datetime,
  updated_at datetime
)
      SQL
      )

      stub_const("Post", Class.new(ActiveRecord::Base))
      stub_const("PostProjector", Class.new(RecordProjector))

      PostProjector.class_eval do
        self.record_class = 'Post'
      end
    end

    context "initialize" do
      it "initializes a new record" do
        projector = PostProjector.new(aggregate_id: aggregate_id)
        expect(projector.record).to be_new_record
        expect(projector.record.id).to eq(aggregate_id)
      end

      it "finds an existing record" do
        Post.create!(id: aggregate_id)
        projector = PostProjector.new(aggregate_id: aggregate_id)
        expect(projector.record).to be_persisted
        expect(projector.record.changed?).to be_falsey
        expect(projector.record.id).to eq(aggregate_id)
      end
    end

    context "apply_event" do
      it "invokes the event binding with changes the record" do
        stub_const("TitleChanged", Class.new(Event))
        stub_const("PublishedChanged", Class.new(Event))

        PostProjector.class_eval do
          on TitleChanged do |event|
            record.title = event.data.fetch('title')
          end

          on PublishedChanged do |event|
            record.published = event.data.fetch('published')
          end
        end

        projector = PostProjector.new(aggregate_id: aggregate_id)
        projector.apply_event(TitleChanged.new(aggregate_id: aggregate_id,
                                               data: {title: 'new-title'},
                                               version: 1))
        expect(projector.record.title).to eq('new-title')
        expect(projector.record.changes).to eq({
          'id' => [nil, aggregate_id],
          'title' => [nil, 'new-title']
        })

        projector.apply_event(PublishedChanged.new(aggregate_id: aggregate_id,
                                               data: {published: true},
                                               version: 2))
        expect(projector.record.published).to be_truthy
        expect(projector.record.changes).to eq({
          'id' => [nil, aggregate_id],
          'title' => [nil, 'new-title'],
          'published' => [nil, true]
        })
      end

      it "ignores unknown events" do
        stub_const("UnknownEvent", Class.new(Event))
        projector = PostProjector.new(aggregate_id: aggregate_id)
        projector.apply_event(UnknownEvent.new(aggregate_id: aggregate_id))
        expect(projector.record.changes).to eq({
          'id' => [nil, aggregate_id]
        })
      end
    end

    context "save" do
      it "saves the record" do
        projector = PostProjector.new(aggregate_id: aggregate_id)
        expect(projector.record).to be_new_record
        projector.save
        expect(projector.record).to be_persisted
      end
    end

    context "#call" do
      it "applies events and saves" do
        stub_const("TitleChanged", Class.new(Event))

        PostProjector.class_eval do
          on TitleChanged do |event|
            record.title = event.data.fetch('title')
          end
        end

        projector = PostProjector.new(aggregate_id: aggregate_id)
        expect(projector.record).to be_new_record

        projector.call(
          TitleChanged.new(aggregate_id: aggregate_id,
                           data: {title: 'post-title'},
                           version: 1),
          TitleChanged.new(aggregate_id: aggregate_id,
                           data: {title: 'post-title-v2'},
                           version: 2)
        )
        expect(projector.record).to be_persisted
        expect(projector.record.title).to eq('post-title-v2')
        expect(projector.record.created_at).to eq(projector.record.updated_at)
      end
    end

    context "::call" do
      it "applies and saves grouped events for aggregates" do
        expect(Post.count).to be_zero
        stub_const("TitleChanged", Class.new(Event))

        PostProjector.class_eval do
          on TitleChanged do |event|
            record.title = event.data.fetch('title')
          end
        end

        post_1_id = SecureRandom.uuid
        post_2_id = SecureRandom.uuid
        post_3_id = SecureRandom.uuid

        PostProjector.call(
          TitleChanged.new(aggregate_id: post_1_id,
                           version: 1,
                           data: {title: 'post_1-title-v1'}),
          TitleChanged.new(aggregate_id: post_2_id,
                           version: 1,
                           data: {title: 'post_2-title-v1'}),
          TitleChanged.new(aggregate_id: post_3_id,
                           version: 1,
                           data: {title: 'post_3-title-v1'}),
          TitleChanged.new(aggregate_id: post_1_id,
                           version: 2,
                           data: {title: 'post_1-title-v2'}),
          TitleChanged.new(aggregate_id: post_3_id,
                           version: 2,
                           data: {title: 'post_3-title-v2'}),
          TitleChanged.new(aggregate_id: post_1_id,
                           version: 3,
                           data: {title: 'post_1-title-v3'}),
        )

        expect(Post.count).to eq(3)

        post_1 = Post.find(post_1_id)
        expect(post_1.title).to eq('post_1-title-v3')

        post_2 = Post.find(post_2_id)
        expect(post_2.title).to eq('post_2-title-v1')

        post_3 = Post.find(post_3_id)
        expect(post_3.title).to eq('post_3-title-v2')
      end
    end
  end
end
