class AddDeletedAtToBudgetItems < ActiveRecord::Migration[5.1]
  def change
    add_column :budget_items, :deleted_at, :timestamp
  end
end
