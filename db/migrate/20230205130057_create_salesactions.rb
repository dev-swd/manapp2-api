class CreateSalesactions < ActiveRecord::Migration[6.1]
  def change
    create_table :salesactions do |t|
      t.string :name
      t.integer :sort_key
      t.integer :color_r
      t.integer :color_g
      t.integer :color_b
      t.decimal :color_a, precision: 3, scale: 2
      t.timestamps
    end
  end
end
