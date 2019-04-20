class Budget::Metadata
  def self.for(budget_interval = Budget::Interval.current)
    new(budget_interval).call
  end

  def initialize(budget_interval)
    @budget_interval = budget_interval
  end

  delegate :current?, :date_hash, :days_remaining, :total_days, to: :budget_interval

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
    @spent ||= DiscretionaryTransactions.for(budget_interval).total
  end

  def balance
    @balance ||= current? ? (Account.available_cash + Account.charged).to_i : 0
  end

  attr_reader :budget_interval
end
