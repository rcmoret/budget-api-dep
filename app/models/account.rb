class Account < ActiveRecord::Base
  has_many :transactions, class_name: 'Base::Transaction'

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
    transactions.sum(:amount)
  end
end
