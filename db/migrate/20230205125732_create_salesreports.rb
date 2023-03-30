class CreateSalesreports < ActiveRecord::Migration[6.1]
  def change
    create_table :salesreports do |t|
      t.references :prospect, index: true, foreign_key: true
      t.date :report_date
      t.bigint :make_id
      t.bigint :update_id
      t.bigint :salesaction_id
      t.string :topics
      t.text :content
      t.timestamps
    end
  end
end
