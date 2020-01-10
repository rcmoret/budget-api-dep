# frozen_string_literal: true

class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.string  :description
      t.integer :amount
      t.date :clearance_date
      t.string :check_number
      t.integer :account_id, index: true
      t.integer :budget_item_id, index: true
      t.integer :primary_transaction_id
      t.text :notes
      t.string :receipt
      t.boolean :budget_exclusion, default: false
      t.integer :transfer_id, index: true

      t.timestamps
    end
    add_foreign_key :transactions, :accounts
  end
end
