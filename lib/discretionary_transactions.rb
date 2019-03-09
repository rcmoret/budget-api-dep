class DiscretionaryTransactions
  attr_reader :budget_month

  def self.for(budget_month = BudgetMonth.new)
    new(budget_month)
  end

  def initialize(budget_month)
    @budget_month = budget_month
  end

  delegate :current?, :date_hash, :date_range, :days_remaining, :total_days, to: :budget_month

  def collection
    @collection ||=
      Transaction::Record.between(date_range, include_pending: current?)
        .discretionary
        .ordered
  end

  def total
    collection.total.to_i
  end

  private

  def balance
    @balance ||= current? ? Account.available_cash.to_i + Account.charged.to_i : 0
  end

end
