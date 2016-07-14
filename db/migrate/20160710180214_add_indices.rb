class AddIndices < ActiveRecord::Migration
  def change
    add_index :transactions, :account_id
    add_index :transactions, :primary_transaction_id
    add_index :monthly_amounts, :budget_item_id
  end
end
