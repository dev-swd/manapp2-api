class CreateMembers < ActiveRecord::Migration[6.1]
  def change
    create_table :members do |t|
      t.references :project, index: true, foreign_key: true
      t.integer :number
      t.string :level
      t.bigint :member_id
      t.string :tag
      t.timestamps
    end
  end
end
