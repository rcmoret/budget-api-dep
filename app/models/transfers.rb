class Transfer < ActiveRecord::Base
  has_one :from_transaction, class_name: 'Transaction::Record'
  has_one :to_transaction, class_name: 'Transaction::Record'

  def self.generate(from_account:, to_account:, amount:)
    transfer = new
    from_transaction = from_account.primary_transactions.create(description: "Transfer to #{to_account.name}", amount: -amount)
    to_transaction = to_account.primary_transactions.create(description: "Transfer from #{from_account.name}", amount: amount)
    transfer.to_transaction_id = to_transaction.id
    transfer.from_transaction_id = from_transaction.id
    transfer.save
  end
end
