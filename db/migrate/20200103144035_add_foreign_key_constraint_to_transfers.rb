# frozen_string_literal: true

class AddForeignKeyConstraintToTransfers < ActiveRecord::Migration[5.1]
  def up
    add_foreign_key :transfers, :transaction_entries, column: :to_transaction_id
    add_foreign_key :transfers,
                    :transaction_entries,
                    column: :from_transaction_id
  end

  def down
    remove_foreign_key :transfers, :transaction_entries
    remove_foreign_key :transfers, :transaction_entries
  end
end
