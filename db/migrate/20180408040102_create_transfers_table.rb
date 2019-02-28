class CreateTransfersTable < ActiveRecord::Migration[5.1]
  def change
    create_table :transfers do |t|
      t.integer :to_transaction_id, null: false
      t.integer :from_transaction_id, null: false

      t.timestamps
    end

    add_foreign_key :transactions, :transfers
    add_foreign_key :transfers, :transactions, column: :to_transaction_id
    add_foreign_key :transfers, :transactions, column: :from_transaction_id
  end
end
