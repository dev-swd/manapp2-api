class CreateLeads < ActiveRecord::Migration[6.1]
  def change
    create_table :leads do |t|
      t.string :name
      t.string :period_kbn
      t.integer :period
      t.integer :sort_key
      t.integer :color_r
      t.integer :color_g
      t.integer :color_b
      t.decimal :color_a, precision: 3, scale: 2
      t.timestamps
    end
  end
end
