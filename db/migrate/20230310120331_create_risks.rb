class CreateRisks < ActiveRecord::Migration[6.1]
  def change
    create_table :risks do |t|
      t.references :project, index: true, foreign_key: true
      t.integer :number
      t.text :contents
      t.timestamps
    end
  end
end
