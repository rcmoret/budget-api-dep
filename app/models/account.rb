class Account < ActiveRecord::Base
  has_many :transaction_views, class_name: 'Transaction::View'
  has_many :transactions, class_name: 'Transaction::Record'
  has_many :primary_transactions, class_name: 'Primary::Transaction'
  scope :active, -> { where(archived_at: nil) }
  scope :by_priority, -> { order('priority asc') }
  scope :cash_flow, -> { where(cash_flow: true) }
  scope :non_cash_flow, -> { where(cash_flow: false) }
  validates_presence_of :name, :priority
  validates_uniqueness_of :name, :priority

  PUBLIC_ATTRS = %w(name cash_flow priority).freeze

  class << self
    def total
      sum(:amount)
    end

    def available_cash
      cash_flow.joins(:transactions).total
    end

    def charged(budget_month = BudgetMonth.new)
      non_cash_flow.joins(:transactions).merge(
        Transaction::Record.budget_inclusions.between(
          budget_month.date_range, include_pending: budget_month.current?
        )
      ).total
    end

    def balance_prior_to(date)
      cash_flow.joins(:transactions).merge(
        Transaction::Record.cleared.prior_to(date)
      ).total
    end
  end

  delegate :to_json, to: :to_hash

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
    transactions.cleared.maximum(:clearance_date)
  end

  def oldest_clearance_date
    transactions.cleared.minimum(:clearance_date)
  end

  def deleted?
    archived_at.present?
  end

  def destroy
    transactions.any? ? update(archived_at: Time.current) : super
  end

  def to_s
    name
  end
end
