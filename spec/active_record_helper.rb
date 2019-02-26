require "active_record"

RSpec.configure do |config|
  config.before do
    ActiveRecord::Base.establish_connection(
      adapter: :sqlite3,
      dbfile: ':memory:',
      database: ':memory:'
    )

    ActiveRecord::Base.connection.execute(<<~SQL
create table fourd_commands (
id integer primary key autoincrement,
aggregate_id uuid not null,
command_type text not null,
data text,
created_at datetime,
updated_at datetime
)
    SQL
    )

    ActiveRecord::Base.connection.execute(<<~SQL
create table fourd_events (
id integer primary key autoincrement,
uuid uuid not null,
aggregate_id uuid not null,
event_type text not null,
data text,
metadata text,
version integer,
created_at datetime,
updated_at datetime
);
    SQL
    )
  end

  config.after do
    ActiveRecord::Base.clear_all_connections!
  end
end
