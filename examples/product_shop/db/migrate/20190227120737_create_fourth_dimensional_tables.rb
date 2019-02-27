class CreateFourthDimensionalTables < ActiveRecord::Migration[5.2]
  def change
    create_table :fourd_commands do |t|
      t.uuid :aggregate_id, null: false
      t.string :command_type, null: false
      t.text :data
      t.timestamps null: false
    end

    create_table :fourd_events do |t|
      t.uuid :uuid, null: false
      t.uuid :aggregate_id, null: false
      t.integer :version, null: false
      t.string :event_type, null: false
      t.text :data, null: false
      t.text :metadata, null: false
      t.timestamps null: false
    end
  end
end
