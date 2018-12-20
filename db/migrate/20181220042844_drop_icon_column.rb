class DropIconColumn < ActiveRecord::Migration[5.1]
  def change
    remove_column :budget_items, :icon, :string
  end
end
