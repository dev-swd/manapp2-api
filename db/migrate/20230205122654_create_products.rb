class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string :code
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
