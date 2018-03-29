class AddArchivedToItems < ActiveRecord::Migration[5.1]
  def change
    add_column :budget_items, :archived_at, :timestamp
  end
end
