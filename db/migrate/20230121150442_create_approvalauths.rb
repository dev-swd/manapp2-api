class CreateApprovalauths < ActiveRecord::Migration[6.1]
  def change
    create_table :approvalauths do |t|
      t.references :user, index: true, foreign_key: true
      t.references :division, index: true, foreign_key: true
      t.timestamps
    end
  end
end
