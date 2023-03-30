class CreateLeadlogs < ActiveRecord::Migration[6.1]
  def change
    create_table :leadlogs do |t|
      t.references :prospect, index: true, foreign_key: true
      t.bigint :lead_id
      t.timestamps
    end
  end
end
