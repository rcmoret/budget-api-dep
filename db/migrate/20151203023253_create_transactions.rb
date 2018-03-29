class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.string   :description
      t.decimal  :amount
      t.date     :clearance_date
      t.integer  :check_number
      t.integer  :account_id
      t.integer  :monthly_amount_id,         index: true
      t.integer  :budget_item_id
      t.integer  :primary_transaction_id
      t.text     :notes
      t.string   :receipt
      t.boolean  :qualified_medical_expense, default: false
      t.boolean  :tax_deduction,             default: false

      t.timestamps
    end
    add_foreign_key :transactions, :accounts
  end
end
