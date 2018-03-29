class CreateMonthlyAmounts < ActiveRecord::Migration[5.1]
  def change
    create_table :monthly_amounts do |t|
      t.string :month
      t.decimal :amount
      t.integer :budget_item_id
    end
    add_foreign_key :monthly_amounts, :budget_items
  end
end
