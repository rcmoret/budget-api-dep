class Discretionary
  attr_reader :budget_month

  def initialize(budget_month = BudgetMonth.new)
    @budget_month = budget_month
  end

  delegate :current?, :date_hash, :date_range, :days_remaining,
                      :first_day, :status, :total_days, to: :budget_month

  def to_hash
    {
      name: 'Discretionary',
      spent: spent,
      over_under_budget: over_under_budget,
      remaining: {
        remaining_budgeted: remaining_budgeted,
        available_cash: available_cash,
        charged: charged,
      },
      expense: true,
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

  def available_cash
    @available_cash ||= Account.available_cash.to_i
  end

  def beginning_balance
    @beginning_balance ||= Account.balance_prior_to(first_day).to_i
  end

  def remaining_budgeted
    @remaining_budgeted ||= Budget::Item.remaining_for(date_hash).to_i
  end

  def charged
    @charged ||= Account.charged.to_i
  end

  def spent
    @spent ||= transactions.total.to_i
  end

  def over_under_budget
    @over_under_budget ||= Budget::Item.over_under_budget(date_hash).to_i
  end
end
