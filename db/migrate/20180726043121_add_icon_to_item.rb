class AddIconToItem < ActiveRecord::Migration[5.1]
  def change
    add_column :budget_items, :icon, :string
  end
end
