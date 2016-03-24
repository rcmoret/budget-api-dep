class Account < ActiveRecord::Base
  has_many :transactions, class_name: 'View::Transaction'
  has_many :primary_transactions, class_name: 'Primary::Transaction'

  def to_hash
    {
      id: id,
      name: name,
      balance: balance.to_f.round(2),
      cash_flow: cash_flow,
      health_savings_account: health_savings_account
    }
  end

  def balance(prior_to: nil)
    if prior_to.nil?
      transactions.sum(:amount).to_f
    else
      transactions.prior_to(prior_to).sum(:amount).to_f
    end
  end

  def transaction_collection(**query_opts)
    return transactions.in_month if query_opts.empty?
    transactions.query_with(query_opts)
  end
end
