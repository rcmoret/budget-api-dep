class RenameBudgetMonth < ActiveRecord::Migration[5.1]
  def change
    execute('DROP VIEW IF EXISTS budget_item_views')
    rename_column :budget_items, :budget_month_id, :budget_interval_id
    rename_table :budget_months, :budget_intervals
  end
end
