class Account < ActiveRecord::Base
  has_many :transactions, class_name: 'Transaction::View'
  has_many :primary_transactions, class_name: 'Primary::Transaction'
  scope :active, -> { where(deleted_at: nil) }
  scope :by_priority, -> { order('priority asc') }
  scope :cash_flow, -> { where(cash_flow: true) }
  scope :non_cash_flow, -> { where(cash_flow: false) }

  PUBLIC_ATTRS = %w(name cash_flow health_savings_account).freeze

  def self.available_cash
    cash_flow.joins(:transactions).sum(:amount).to_f
  end

  def self.charged(budget_month = BudgetMonth.new)
    non_cash_flow.joins(:transactions).merge(
      transactions.between(budget_month.date_range, include_pending: budget_month.current?).budget_included
    ).sum(:amount).to_f
  end

  def self.balance_prior_to(date)
    cash_flow.joins(:transactions).merge(Transaction::View.cleared.prior_to(date)).sum(:amount).to_f
  end

  def to_hash
    attributes.symbolize_keys.merge(balance: balance)
  end

  def balance(prior_to: nil)
    if prior_to.nil?
      transactions.total
    else
      transactions.prior_to(prior_to).total
    end
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
