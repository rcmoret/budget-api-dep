class CreateBudgetItemEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :budget_item_events do |t|
      t.references :budget_item
      t.references :budget_item_event_type
      t.integer :amount, null: false
      t.json :data

      t.timestamps
    end
  end
end
