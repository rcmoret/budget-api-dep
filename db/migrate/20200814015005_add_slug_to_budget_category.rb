class AddSlugToBudgetCategory < ActiveRecord::Migration[6.0]
  def change
    add_column :budget_categories, :slug, :string
    add_index :budget_categories, :slug, unique: true
  end
end
