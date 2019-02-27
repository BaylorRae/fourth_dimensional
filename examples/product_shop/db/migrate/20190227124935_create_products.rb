class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string :title
      t.text :body
      t.decimal :price, precision: 10, scale: 2

      t.timestamps
    end
  end
end
