class CreateProjects < ActiveRecord::Migration[6.1]
  def change
    create_table :projects do |t|
      t.string :status
      t.bigint :approval_id
      t.date :approval_date
      t.bigint :division_id
      t.bigint :pl_id
      t.string :number
      t.string :name
      t.date :make_date
      t.bigint :make_id
      t.date :update_date
      t.bigint :update_id
      t.string :company_name
      t.string :department_name
      t.string :personincharge_name
      t.string :phone
      t.string :fax
      t.string :email
      t.date :development_period_fr
      t.date :development_period_to
      t.date :scheduled_to_be_completed
      t.text :system_overview
      t.text :development_environment
      t.bigint :order_amount
      t.bigint :planned_work_cost
      t.decimal :planned_workload, precision: 5, scale: 2
      t.bigint :planned_purchasing_cost
      t.bigint :planned_outsourcing_cost
      t.decimal :planned_outsourcing_workload, precision: 5, scale: 2
      t.bigint :planned_expenses_cost
      t.bigint :gross_profit
      t.string :work_place_kbn
      t.string :work_place
      t.string :customer_property_kbn
      t.string :customer_property
      t.string :customer_environment
      t.string :purchasing_goods_kbn
      t.string :purchasing_goods
      t.string :outsourcing_kbn
      t.string :outsourcing
      t.string :customer_requirement_kbn
      t.string :customer_requirement
      t.text :remarks
      t.string :plan_approval
      t.date :plan_approval_date
      t.boolean :not_project, default: false, null: false
      t.bigint :created_id
      t.bigint :updated_id
      t.timestamps
    end
  end
end
