module Budget
  class WeeklyItem < ActiveRecord::Base
    include Budget::Shared

    self.primary_key = :id

    delegate :days_remaining, :total_days, to: :budget_month

    def readonly?
      true
    end

    def to_hash
      super.merge(
        spent: total,
        days_remaining: days_remaining,
        total_days: total_days,
      )
    end

    private

    def budget_month
      @budget_month ||= BudgetMonth.new(month: month, year: year)
    end
  end
end
