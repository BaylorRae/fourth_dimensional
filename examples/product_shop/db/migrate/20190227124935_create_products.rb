class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    enable_extension('pgcrypto')

    create_table :products, id: :uuid do |t|
      t.string :title
      t.text :body
      t.decimal :price, precision: 10, scale: 2

      t.timestamps
    end
  end
end
