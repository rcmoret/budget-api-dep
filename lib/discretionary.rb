class Discretionary
  attr_reader :budget_month

  def initialize(budget_month = BudgetMonth.new)
    @budget_month = budget_month
  end

  delegate :current?, :date_range, :days_remaining, :total_days, to: :budget_month

  def to_hash
    {
      spent: spent,
      balance: balance,
      days_remaining: days_remaining,
      total_days: total_days,
    }
  end

  def transactions
    @transactions ||=
      Transaction::Record.between(date_range, include_pending: current?)
        .discretionary
        .ordered
  end

  private

  def balance
    @balance ||= Account.available_cash.to_i + Account.charged.to_i
  end

  def spent
    transactions.total.to_i
  end
end
