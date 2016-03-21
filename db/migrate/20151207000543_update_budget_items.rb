class UpdateBudgetItems < ActiveRecord::Migration
  def up
    rename_column :budget_items, :amount, :default_amount
    remove_column :budget_items, :previously_accrued
    remove_column :budget_items, :accrual_last_updated
    remove_column :transactions, :budget_item_id
  end

  def down
    rename_column :budget_items, :default_amount, :amount
    add_column :budget_items, :previously_accrued, :decimal, default: 0
    add_column :budget_items, :accrual_last_updated, :datetime
    add_column :transactions, :budget_item_id, :integer
  end
end
