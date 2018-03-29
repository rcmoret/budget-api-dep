class RemoveLegacyColumns < ActiveRecord::Migration[5.1]
  def up
    remove_column :budget_items, :sink_fund
    remove_column :budget_items, :show_if_zero_budgeted
  end

  def down
    add_column :budget_items, :sink_fund, :boolean, default: false
    add_column :budget_items, :show_if_zero_budgeted, :boolean, default: true
  end
end
