class Discretionary
  attr_reader :budget_month

  def initialize(budget_month = BudgetMonth.new)
    @budget_month = budget_month
  end

  def to_hash
    {
      name: 'Discretionary',
      amount: amount,
      spent: spent,
      over_under_budget: over_under_budget,
      remaining: remaining,
      budgeted_per_day: budgeted_per_day,
      budgeted_per_week: budgeted_per_week,
      remaining_per_day: remaining_per_day,
      remaining_per_week: remaining_per_week,
    }
  end

  def transactions
    @transactions ||=
      Transaction::Record.between(budget_month.date_range, include_pending: budget_month.current?)
        .discretionary
        .ordered
  end

  private

  def remaining
    @remaining ||= determine_remaining.to_i
  end

  def determine_remaining
    case budget_month.status
    when :current
      available_cash + remaining_budgeted + charged
    when :future
      Budget::Item.in(budget_month.date_hash).sum(:amount)
    when :past
      beginning_balance + remaining_budgeted + over_under_budget + spent
    end
  end

  def available_cash
    @available_cash ||= Account.available_cash
  end

  def beginning_balance
    @beginning_balance ||= Account.balance_prior_to(budget_month.first_day)
  end

  def remaining_budgeted
    @remaining_budgeted ||= Budget::Item.remaining_for(budget_month.date_hash)
  end

  def charged
    @charged ||= Account.charged
  end

  def amount
    @amount ||= (remaining - spent - over_under_budget).to_i
  end

  def spent
    @spent ||= transactions.total
  end

  def over_under_budget
    @over_under_budget ||= Budget::Item.over_under_budget(budget_month.date_hash)
  end

  def budgeted_per_day
    @budgeted_per_day ||= (amount / budget_month.total_days)
  end

  def remaining_per_day
    @remaining_per_day ||= if budget_month.current?
                             (remaining / budget_month.days_remaining)
                           else
                             budgeted_per_day
                           end
  end

  def remaining_per_week
    @remaining_per_week ||= (remaining_per_day * 7)
  end

  def budgeted_per_week
    @budgeted_per_week ||= (budgeted_per_day * 7)
  end
end
