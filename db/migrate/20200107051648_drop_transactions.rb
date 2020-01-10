# frozen_string_literal: true

class DropTransactions < ActiveRecord::Migration[5.1]
  def up
    remove_foreign_key :transactions, :accounts
    remove_foreign_key :transactions, :budget_items
    drop_table :transactions
  end

  def down
    create_table :transactions do |t|
      t.string 'description'
      t.integer 'amount'
      t.date 'clearance_date'
      t.string 'check_number'
      t.integer 'account_id'
      t.integer 'budget_item_id'
      t.integer 'primary_transaction_id'
      t.text 'notes'
      t.string 'receipt'
      t.boolean 'budget_exclusion', default: false
      t.integer 'transfer_id'
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
    end

    add_foreign_key :transactions, :accounts
    add_foreign_key :transactions, :budget_items
  end
end
