class AddForeignKeyForSubtransactions < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :transactions, :transactions, column: :primary_transaction_id, primary_key: :id
  end
end
