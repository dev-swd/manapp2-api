class CreateApplicationtemps < ActiveRecord::Migration[6.1]
  def change
    create_table :applicationtemps do |t|
      t.string :code
      t.string :name
      t.integer :sort_key
      t.timestamps
    end
  end
end
