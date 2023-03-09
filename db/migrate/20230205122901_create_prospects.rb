class CreateProspects < ActiveRecord::Migration[6.1]
  def change
    create_table :prospects do |t|
      t.string :name
      t.bigint :division_id
      t.bigint :make_id
      t.bigint :update_id
      t.string :company_name
      t.string :department_name
      t.string :person_in_charge_name
      t.string :phone
      t.string :fax
      t.string :email
      t.bigint :product_id
      t.bigint :lead_id
      t.text :content
      t.date :period_fr
      t.date :period_to
      t.bigint :main_person_id
      t.bigint :order_amount
      t.string :sales_channels
      t.string :sales_person
      t.date :closing_date
      t.date :lost_date
      t.date :delete_date
      t.timestamps
    end
  end
end
