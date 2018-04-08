class Discretionary
  attr_reader :month

  def initialize(month = BudgetMonth.new)
    @month = month
  end

  def to_hash
    { id: 0, name: 'Discretionary', amount: amount, remaining: remaining, spent: spent,
      month: month.piped, item_id: 0, days_remaining: month.days_remaining }
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
    @amount ||= remaining - spent
  end

  def spent
    @spent ||= transactions.sum(:amount)
  end
end
