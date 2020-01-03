# frozen_string_literal: true

class CreateTransactionEntries < ActiveRecord::Migration[5.1]
  def up
    create_table :transaction_entries do |t|
      t.string :description, limit: 255
      t.string :check_number, limit: 12
      t.date :clearance_date
      t.references :account, foreign_key: true, null: false
      t.text :notes
      t.boolean :budget_exclusion
      t.references :transfer, foreign_key: true, null: true
      t.string :receipt, limit: 255

      t.timestamps
    end
  end

  def down
    drop_table :transaction_entries
  end
end
