class CreateBudgetItemEventTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :budget_item_event_types do |t|
      t.string :name, null: false, limit: 50

      t.timestamps
    end

    add_index :budget_item_event_types, :name, unique: true
  end
end
