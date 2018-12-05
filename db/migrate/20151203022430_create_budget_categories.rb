class CreateBudgetCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :budget_categories do |t|
      t.string :name
      t.integer :default_amount, null: false
      t.boolean :monthly, default: true
      t.boolean :expense, default: true
      t.timestamp :archived_at

      t.timestamps
    end
  end
end
