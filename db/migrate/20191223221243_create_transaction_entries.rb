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

    remove_foreign_key :transfers, :transactions
    remove_foreign_key :transfers, :transactions
    add_foreign_key :transfers, :transaction_entries, column: :to_transaction_id
    add_foreign_key :transfers,
                    :transaction_entries,
                    column: :from_transaction_id
  end

  def down
    drop_table :transaction_entries
    add_foreign_key :transfers, :transactions, column: :to_transaction_id
    add_foreign_key :transfers, :transactions, column: :from_transaction_id
    remove_foreign_key :transfers, :transaction_entries
    remove_foreign_key :transfers, :transaction_entries
  end
end
