class Transfer < ActiveRecord::Base
  belongs_to :from_transaction, class_name: 'Transaction::Record'
  belongs_to :to_transaction, class_name: 'Transaction::Record'

  def self.generate(from_account:, to_account:, amount:)
    transfer = new
    from_transaction = transfer.build_from_transaction(
      account_id: from_account.id, description: "Transfer to #{to_account.name}", amount: -amount)
    to_transaction = transfer.build_to_transaction(
      account_id: to_account.id, description: "Transfer from #{from_account.name}", amount: amount)
    transfer.save
    from_transaction.update(transfer_id: transfer.id)
    to_transaction.update(transfer_id: transfer.id)
  end
end
