# frozen_string_literal: true

class CreateTransactionDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :transaction_details do |t|
      t.references :transaction_entry, foreign_key: true, null: false
      t.references :budget_item, foreign_key: true, null: true
      t.integer :amount, null: false

      t.timestamps
    end
  end
end
