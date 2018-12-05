class CreateBudgetItems < ActiveRecord::Migration[5.1]
  def change
    create_table :budget_items do |t|
      t.integer :month
      t.integer :year
      t.integer :amount
      t.integer :budget_category_id

      t.timestamps
    end

    add_foreign_key :budget_items, :budget_categories
    add_foreign_key :transactions, :budget_items
  end
end
