class Account < ActiveRecord::Base
  has_many :transactions

  def to_hash
    {
      id: id,
      name: name,
      balance: balance.to_f.round(2),
      cash_flow: cash_flow,
      health_savings_account: health_savings_account
    }
  end

  def balance
    Transaction.unscoped.where(account_id: id).sum(:amount)
  end

  def transaction_collection(**query_opts)
    if query_opts.empty?
      transactions.in_month
    else
      transactions.query_with(query_opts)
    end
  end
end
