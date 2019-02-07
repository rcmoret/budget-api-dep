module Budget
  class MonthlyItem < Item

    default_scope { monthly.includes(:category) }

    TRANSACTIONS_JOIN = %Q{LEFT JOIN (#{::Transaction::Record.all.to_sql}) t ON t.budget_item_id = "budget_items".id}.freeze

    scope :anticipated, -> { joins(TRANSACTIONS_JOIN).where('t.id IS NULL') }
    scope :cleared, -> { joins(TRANSACTIONS_JOIN).where('t.id IS NOT NULL') }

    def readonly?
      true
    end

    def to_hash
      attributes.merge(spent: spent, deletable: deletable?)
    end

    private

    def spent
      transactions.total
    end

    def deletable?
      transactions.none?
    end
  end
end
