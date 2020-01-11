# frozen_string_literal: true

class CreateBudgetMonths < ActiveRecord::Migration[5.1]
  def change
    create_table :budget_months do |t|
      t.integer :month, null: false
      t.integer :year, null: false
      t.datetime :set_up_completed_at
      t.datetime :close_out_completed_at

      t.timestamps
    end
  end
end
