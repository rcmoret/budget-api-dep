# frozen_string_literal: true

class BudgetCategoryMaturityInterval < ActiveRecord::Migration[5.1]
  def change
    create_table :budget_category_maturity_intervals do |t|
      t.integer :budget_interval_id, null: false
      t.integer :budget_category_id, null: false
    end

    add_foreign_key :budget_category_maturity_intervals, :budget_intervals
    add_foreign_key :budget_category_maturity_intervals, :budget_categories
    add_index :budget_category_maturity_intervals,
              %i[budget_category_id budget_interval_id],
              name: 'index_category_interval_uniqueness',
              unique: true
  end
end
