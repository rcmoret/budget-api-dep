# frozen_string_literal: true

class DropMonthYearCols < ActiveRecord::Migration[5.1]
  def change
    remove_column :budget_items, :month
    remove_column :budget_items, :year
  end
end
