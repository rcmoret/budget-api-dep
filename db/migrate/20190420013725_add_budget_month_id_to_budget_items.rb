class AddBudgetMonthIdToBudgetItems < ActiveRecord::Migration[5.1]
  def change
    add_column :budget_items, :budget_month_id, :integer
  end
end
