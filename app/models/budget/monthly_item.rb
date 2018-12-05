module Budget
  class MonthlyItem < Item
    default_scope { monthly.includes(:category) }

    TRANSACTIONS_JOIN = %Q{LEFT JOIN (#{::Transaction::Record.all.to_sql}) t ON t.budget_item_id = "budget_items".id}.freeze

    scope :anticipated, -> { joins(TRANSACTIONS_JOIN).where('t.id IS NULL') }
    scope :cleared, -> { joins(TRANSACTIONS_JOIN).where('t.id IS NOT NULL') }

    def self.remaining
      anticipated.sum(:amount)
    end

    def self.over_under_budget
      cleared.sum('t.amount') - cleared.sum(:amount)
    end

    def readonly?
      true
    end
  end
end
