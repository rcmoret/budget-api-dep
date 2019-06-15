module Budget
  class CategoryMaturityInterval < ActiveRecord::Base
    belongs_to :interval, foreign_key: :budget_interval_id
    belongs_to :category, foreign_key: :budget_category_id

    validates :category, uniqueness: { scope: :interval }
    validate :category_accrual?

    scope :ordered, -> { joins(:interval).merge(Interval.ordered) }

    private

    def category_accrual?
      return if category.accrual?
      errors.add(:budget_category, 'must be an accrual')
    end
  end
end
