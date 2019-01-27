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
      amount: amount,
      spent: spent,
      over_under_budget: over_under_budget,
      remaining: {
        remaining_budgeted: remaining_budgeted,
        available_cash: available_cash,
        charged: charged,
        total: remaining,
      },
      expense: true,
      budgeted_per_day: budgeted_per_day,
      budgeted_per_week: budgeted_per_week,
      remaining_per_day: remaining_per_day,
      remaining_per_week: remaining_per_week,
      days_remaining: days_remaining,
    }
  end

  def transactions
    @transactions ||=
      Transaction::Record.between(date_range, include_pending: current?)
        .discretionary
        .ordered
  end

  private

  def remaining
    @remaining ||= determine_remaining.to_i
  end

  def determine_remaining
    case status
    when :current
      available_cash + remaining_budgeted + charged
    when :future
      Budget::Item.in(date_hash).sum(:amount)
    when :past
      beginning_balance + remaining_budgeted + over_under_budget + spent
    end
  end

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

  def amount
    @amount ||= (remaining - spent - over_under_budget).to_i
  end

  def spent
    @spent ||= transactions.total.to_i
  end

  def over_under_budget
    @over_under_budget ||= Budget::Item.over_under_budget(date_hash).to_i
  end

  def budgeted_per_day
    @budgeted_per_day ||= (amount / total_days).to_i
  end

  def remaining_per_day
    @remaining_per_day ||= current? ? (remaining / days_remaining).to_i : budgeted_per_day
  end

  def remaining_per_week
    @remaining_per_week ||= (remaining_per_day * 7).to_i
  end

  def budgeted_per_week
    @budgeted_per_week ||= (budgeted_per_day * 7)
  end
end
