class BudgetedAmount < ActiveRecord::Base
  self.table_name = 'monthly_amounts'
  has_many :transactions, class_name: 'Base::Transaction', foreign_key: :monthly_amount_id

  belongs_to :budget_item
  validates :budget_item, presence: true
  delegate :default_amount, :expense?, :revenue?, to: :budget_item

  validates :amount, numericality: { less_than: 0 }, if: :expense?
  validates :amount, numericality: { greater_than: 0 }, if: :revenue?

  before_validation :set_month!, if: 'month.nil?'
  before_validation :set_default_amount!, if: 'amount.nil?'

  scope :current, -> { where(month: BudgetMonth.piped) }

  def self.remaining
    MonthlyAmount.remaining + WeeklyAmount.remaining
  end

  private

  def set_default_amount!
    self.amount = default_amount
  end

  def set_month!
    self.month = BudgetMonth.piped
  end
end

class MonthlyAmount < BudgetedAmount

  default_scope { current.joins(:budget_item).merge(BudgetItem.monthly) }

  scope :anticipated, -> { joins("LEFT JOIN (#{::Base::Transaction.all.to_sql}) t " +
                                 'ON t.monthly_amount_id = "monthly_amounts".id').where('t.id IS NULL') }

  def self.remaining
    anticipated.sum(:amount)
  end
end

class WeeklyAmount < MonthlyAmount

  default_scope { current.joins(:budget_item).merge(BudgetItem.weekly) }

  def self.remaining
    all.inject(0) { |total, amount| total += amount.remaining }
  end

  def remaining
    if expense?
      difference < 0 ? difference : 0
    else
      difference > 0 ? difference : 0
    end
  end

  private

  def difference
    amount - transactions.sum(:amount)
  end
end
