class DropUnusedColumns < ActiveRecord::Migration[6.0]
  def up
    remove_column :budget_items, :month
    remove_column :budget_items, :year
  end

  def down
    add_column :budget_items, :month, :integer
    add_column :budget_items, :year, :integer
  end
end
