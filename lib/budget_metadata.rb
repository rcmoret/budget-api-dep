class Budget::Metadata
  def self.for(budget_month = BudgetMonth.new)
    new(budget_month).call
  end

  def initialize(budget_month)
    @budget_month = budget_month
  end

  delegate :current?, :date_hash, :days_remaining, :total_days, to: :budget_month

  def call
    date_hash.merge(
      days_remaining: days_remaining,
      total_days: total_days,
      balance: balance,
      spent: spent
    )
  end

  private

  def spent
    @spent ||= DiscretionaryTransactions.for(budget_month).total
  end

  def balance
    @balance ||= current? ? (Account.available_cash + Account.charged).to_i : 0
  end

  attr_reader :budget_month
end
