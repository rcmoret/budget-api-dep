class AddTransferIdToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :transfer_id, :integer
  end
end
