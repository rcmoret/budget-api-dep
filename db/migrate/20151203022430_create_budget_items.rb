class CreateBudgetItems < ActiveRecord::Migration[5.1]
  def change
    create_table :budget_items do |t|
      t.string   :name
      t.decimal  :amount,                null:    false
      t.boolean  :monthly,               default: true
      t.boolean  :expense,               default: true
      t.boolean  :sink_fund,             default: false
      t.decimal  :previously_accrued,    default: 0
      t.datetime :accrual_last_updated
      t.boolean  :show_if_zero_budgeted, default: false

      t.timestamps
    end
  end
end
