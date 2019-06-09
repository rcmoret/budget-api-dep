class AddAccrualToCategory < ActiveRecord::Migration[5.1]
  def change
    add_column :budget_categories, :accrual, :boolean, default: false, null: false
  end
end
