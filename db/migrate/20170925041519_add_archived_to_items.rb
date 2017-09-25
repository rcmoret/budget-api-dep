class AddArchivedToItems < ActiveRecord::Migration
  def change
    add_column :budget_items, :archived_at, :timestamp
  end
end
