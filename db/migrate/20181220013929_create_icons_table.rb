class CreateIconsTable < ActiveRecord::Migration[5.1]
  def change
    create_table :icons do |t|
      t.string :name, limit: 100, null: false
      t.string :class_name, limit: 100, null: false
      t.timestamps
    end

    add_reference :budget_items, :icon, foreign_key: true
  end
end
