# Fourth Dimensional

Fourth Dimensional is an event sourcing library to account for the state of a
system in relation to time.

This project is a lightweight dsl for commands and events for use with
ActiveRecord. Eventually I'd like it to support Sequel as well.

[RDoc][rdoc_url]

[![Build Status]][travis_status]

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fourth_dimensional'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fourth_dimensional

## Usage

This API is in flux, but here's the general idea.

```ruby
class PostAdded < FourthDimensional::Event
  def title
    data.fetch('title')
  end

  def body
    data.fetch('body')
  end

  def published
    data.fetch('published')
  end
end

class AddPost < FourthDimensional::Command
  attributes :title, :body, :published
  validates_presence_of :title, :body
end

class PostCommandHandler < FourthDimensional::CommandHandler
  on AddPost do |command|
    with_aggregate(PostAggregate, command) do |post|
      post.add(title: command.title,
               body: command.body,
               published: command.published)
    end
  end
end

class PostAggregate < FourthDimensional::AggregateRoot
  def add(title:, body:, published:)
    apply(PostAdded,
      data: {
        title: title,
        body: body,
        published: published
      }
    )
  end
end

class PostProjector < FourthDimensional::RecordProjector
  self.record_class = 'Post'

  on PostAdded do |event|
    record.title = event.title
    record.body = event.body
    record.published = event.published
  end
end

def main
  FourthDimensional.configure do |config|
    config.command_handlers = [
      PostCommandHandler
    ]

    config.event_handlers = [
      PostProjector
    ]
  end

  aggregate_id = SecureRandom.uuid

  command = AddPost.new(aggregate_id: aggregate_id,
                        title: 'post-title',
                        body: 'post-body',
                        published: true)

  # persists command and event if successful
  FourthDimensional.execute_commands(command)

  post = Post.find(aggregate_id)
  expect(post.title).to eq('post-title')
  expect(post.body).to eq('post-body')
  expect(post.published).to be_truthy
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/baylorrae/fourth_dimensional.

[rdoc_url]: https://baylorrae.com/fourth_dimensional

[Build Status]: https://travis-ci.org/BaylorRae/fourth_dimensional.svg?branch=master
[travis_status]: https://travis-ci.org/BaylorRae/fourth_dimensional
