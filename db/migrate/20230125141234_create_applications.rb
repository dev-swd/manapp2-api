class CreateApplications < ActiveRecord::Migration[6.1]
  def change
    create_table :applications do |t|
      t.references :applicationrole, index: true, foreign_key: true
      t.references :applicationtemp, index: true, foreign_key: true
      t.boolean :permission, default: false, null: false
      t.timestamps
    end
  end
end
