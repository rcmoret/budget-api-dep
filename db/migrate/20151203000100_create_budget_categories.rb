# frozen_string_literal: true

class CreateBudgetCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :budget_categories do |t|
      t.string :name
      t.integer :default_amount, null: false
      t.boolean :monthly, default: true, null: false
      t.boolean :expense, default: true, null: false
      t.boolean :accrual, default: false, null: false
      t.timestamp :archived_at
      t.references :icon, foreign_key: true, null: true

      t.timestamps
    end
  end
end
