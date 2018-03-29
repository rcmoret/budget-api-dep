class AddBudgetExclusion < ActiveRecord::Migration[5.1]
  def change
    add_column  :transactions, :budget_exclusion, :boolean, default: false
  end
end
