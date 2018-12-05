module Budget
  class WeeklyItem < ActiveRecord::Base
    include Budget::Shared

    self.table_name = :weekly_items
    self.primary_key = :id

    def readonly?
      true
    end

    def self.remaining
      all.map(&:remaining).reduce(:+).to_i
    end

    def self.over_under_budget
      all.map(&:over_under_budget).reduce(:+).to_i
    end

    def remaining
      @remaining ||= expense? ? [difference, 0].min : [difference, 0].max
    end

    def over_under_budget
      extra_income? || over_budget? ? -difference : 0
    end

    def difference
      @difference ||= amount - total
    end

    def to_hash
      super.merge(
        remaining: remaining,
        spent: total,
        budgeted_per_day: budgeted_per_day,
        budgeted_per_week: budgeted_per_week,
        remaining_per_day: remaining_per_day,
        remaining_per_week: remaining_per_week
      )
    end

    private

    def budgeted_per_day
      @budgeted_per_day ||= amount / budget_month.total_days
    end

    def remaining_per_day
      @remaining_per_day ||= remaining / budget_month.days_remaining
    end

    def remaining_per_week
      remaining_per_day * 7
    end

    def budgeted_per_week
      @budgeted_per_week ||= budgeted_per_day * 7
    end

    def budget_month
      @budget_month ||= BudgetMonth.new(month: month, year: year)
    end

    def extra_income?
      revenue? && difference < 0
    end

    def over_budget?
      expense? && difference > 0
    end
  end
end
