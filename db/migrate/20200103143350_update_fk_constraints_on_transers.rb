# frozen_string_literal: true

class UpdateFkConstraintsOnTransers < ActiveRecord::Migration[5.1]
  def up
    remove_foreign_key :transfers, :transactions
    remove_foreign_key :transfers, :transactions
  end

  def down
    add_foreign_key :transfers, :transactions, column: :to_transaction_id
    add_foreign_key :transfers, :transactions, column: :from_transaction_id
  end
end
