class Account < ActiveRecord::Base
  has_many :transactions, class_name: 'Transaction::View'
  has_many :primary_transactions, class_name: 'Primary::Transaction'
  scope :active, -> { where(deleted_at: nil) }
  scope :by_priority, -> { order('priority asc') }

  PUBLIC_ATTRS = %w(name cash_flow health_savings_account).freeze

  def self.available_cash
    where(cash_flow: true).joins(:transactions).sum(:amount).to_f
  end

  def self.charged
    where(cash_flow: false).joins(:transactions).merge(
      Transaction::View.between(BudgetMonth.new.date_range, include_pending: false)
    ).sum(:amount).to_f
  end

  def self.balance_prior_to(date)
    where(cash_flow: true).joins(:transactions).merge(
      Transaction::View.cleared.prior_to(date)
    ).sum(:amount).to_f
  end

  def to_hash
    attributes.symbolize_keys.merge(balance: balance.to_f.round(2))
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

  def newest_clearance_date
    primary_transactions.cleared.maximum(:clearance_date)
  end

  def oldest_clearance_date
    primary_transactions.cleared.minimum(:clearance_date)
  end

  def deleted?
    deleted_at.present?
  end
end
