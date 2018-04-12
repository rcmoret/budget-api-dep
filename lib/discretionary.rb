class Discretionary
  attr_reader :month

  def initialize(month = BudgetMonth.new)
    @month = month
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
      Transaction::Record.between(month.date_range, include_pending: month.current?)
        .discretionary
        .ordered
  end

  private

  def remaining
    @remaining ||= if month.current?
                     (available_cash + remaining_budgeted + charged).round(2)
                   else
                     Budget::Amount.in(month.piped).sum(:amount)
                   end
  end

  def available_cash
    @available_cash ||= Account.available_cash
  end

  def remaining_budgeted
    @remaining_budgeted ||=
      Budget::MonthlyAmount.in(month.piped).remaining + Budget::WeeklyAmount.in(month.piped).remaining
  end

  def charged
    @charged ||= Account.charged
  end

  def amount
    @amount ||= (remaining - spent - over_under_budget).to_f.round(2)
  end

  def spent
    @spent ||= transactions.total
  end

  def cleared_monthly_amounts
    @cleared_monthly_amounts ||= Budget::MonthlyAmount.in(month.piped).cleared
  end

  def cleared_monthly_amount_transactions
    @cleared_monthly_amount_transactions ||=
      Transaction::Record.where(monthly_amount_id: cleared_monthly_amounts.map(&:id))
  end

  def over_under_budget
    @over_under_budget ||= (over_under_budget_monthly + over_under_budget_weekly).to_f.round(2)
  end

  def over_under_budget_monthly
    cleared_monthly_amount_transactions.sum(:amount) - cleared_monthly_amounts.sum(:amount)
  end

  def over_under_budget_weekly
    Budget::WeeklyAmount.in(month.piped).reduce(0) do |total, wa|
      if (wa.expense? && wa.difference > 0) || (wa.revenue? && wa.difference < 0)
        total -= wa.difference
      end
      total
    end
  end

  def budgeted_per_day
    @budgeted_per_day ||= (amount / month.total_days).to_f.round(2)
  end

  def remaining_per_day
    @remaining_per_day ||= (remaining / month.days_remaining).to_f.round(2)
  end

  def remaining_per_week
    @remaining_per_week ||= (remaining_per_day * 7).to_f.round(2)
  end

  def budgeted_per_week
    @budgeted_per_week ||= (budgeted_per_day * 7).to_f.round(2)
  end
end
