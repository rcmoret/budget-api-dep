# frozen_string_literal: true

class CreateBudgetItems < ActiveRecord::Migration[5.1]
  def change
    create_table :budget_items do |t|
      t.integer :month
      t.integer :year
      t.integer :amount
      t.references :budget_category, null: false, foreign_key: true
      t.references :budget_interval, null: false, foreign_key: true

      t.timestamps
    end
  end
end
