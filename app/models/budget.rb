module Budget
  class Item < ActiveRecord::Base
    self.table_name = 'budget_items'
    has_many :amounts, foreign_key: :budget_item_id
    has_many :weekly_amounts, foreign_key: :budget_item_id
    has_many :monthly_amounts, foreign_key: :budget_item_id
    has_many :transactions, through: :amounts
    validates :name, uniqueness: true, presence: true

    scope :monthly,      -> { where(monthly: true) }
    scope :weekly,       -> { where(monthly: false) }
    scope :expenses,     -> { where(expense: true) }
    scope :revenues,     -> { where(expense: false) }
    scope :active,       -> { where(archived_at: nil) }
    scope :search_order, -> (month = BudgetMonth.piped) {
      order(
        %Q{ (select count(*) from monthly_amounts where month = '#{month}' AND budget_item_id = "budget_items".id) = 0 DESC,
            (select count(*) from monthly_amounts where budget_item_id = "budget_items".id) DESC
        }
      )
    }
    delegate :to_json, to: :to_hash

    PUBLIC_ATTRS = %w(id name expense monthly default_amount)

    def default_amount
      self[:default_amount].to_f
    end

    def revenue?
      !expense?
    end

    def to_hash
      attributes.slice(*PUBLIC_ATTRS).symbolize_keys.merge(default_amount: default_amount)
    end

    def archived?
      archived_at.nil?
    end

    def archive!
      update(archived_at: Time.now)
    end

    def unarchive!
      update(archived_at: nil)
    end
  end

  class Amount < ActiveRecord::Base
    self.table_name = 'monthly_amounts'

    has_many :transactions, -> { includes(:account).ordered },
      class_name: 'Transaction::Record', foreign_key: :monthly_amount_id
    belongs_to :item, class_name: 'Budget::Item', foreign_key: :budget_item_id

    delegate :to_json, to: :to_hash
    delegate :name, :default_amount, :expense?, :revenue?, :icon, to: :item

    validates :item, presence: true
    validates :amount, numericality: { less_than_or_equal_to: 0 }, if: :expense?
    validates :amount, numericality: { greater_than_or_equal_to: 0 }, if: :revenue?

    scope :current,  -> { where(month: BudgetMonth.piped) }
    scope :expenses, -> { joins(:item).merge(Budget::Item.expenses).order('amount ASC') }
    scope :revenues, -> { joins(:item).merge(Budget::Item.revenues).order('amount DESC') }
    scope :in,       -> (month = BudgetMonth.piped) { where(month: month) }
    scope :weekly,   -> { joins(:item).merge(Budget::Item.weekly) }
    scope :monthly,  -> { joins(:item).merge(Budget::Item.monthly) }

    alias_attribute :item_id, :budget_item_id

    PUBLIC_ATTRS = %w(amount month).freeze

    def self.budgeted(month = nil)
      self.in(month).sum(:amount).to_f
    end

    def self.active(month = nil)
      (WeeklyAmount.in(month) + MonthlyAmount.in(month).anticipated).sort_by(&:name)
    end

    def item_id=(id)
      budget_item_id=(id)
    end

    def to_hash
      { id: id, name: name, amount: amount, remaining: remaining, spent: spent, icon: icon,
        month: month, item_id: item_id, deletable: deletable?, expense: expense? }
    end

    def amount
      self[:amount].to_f unless self[:amount].nil?
    end

    def remaining
      amount.to_f
    end

    def spent
      transactions.sum(:amount).to_f
    end

    def destroy
      return false unless deletable?
      super
    end

    private

    def deletable?
      transactions.none?
    end
  end

  class MonthlyAmount < Amount

    default_scope { monthly }

    scope :anticipated, -> { joins("LEFT JOIN (#{::Transaction::Record.all.to_sql}) t " +
                                   'ON t.monthly_amount_id = "monthly_amounts".id').where('t.id IS NULL') }
    scope :cleared, -> { joins("LEFT JOIN (#{::Transaction::Record.all.to_sql}) t " +
                               'ON t.monthly_amount_id = "monthly_amounts".id').where('t.id IS NOT NULL') }

    def self.remaining
      anticipated.sum(:amount).to_f
    end

    def remaining
      transactions.any? ? 0 : super
    end
  end

  class WeeklyAmount < Amount

    default_scope { weekly }
    delegate :current?, to: :budget_month
    validates_uniqueness_of :budget_item_id, scope: :month

    def self.remaining
      all.reduce(0) { |total, amount| total += amount.remaining }.to_f
    end

    def remaining
      @remaining ||= expense? ? [difference, 0].min : [difference, 0].max
    end

    def difference
      (amount - transactions.sum(:amount)).to_f.round(2)
    end

    def to_hash
      super.merge(
        budgeted_per_day: budgeted_per_day,
        budgeted_per_week: budgeted_per_week,
        remaining_per_day: remaining_per_day,
        remaining_per_week: remaining_per_week,
      )
    end

    private

    def budgeted_per_day
      (amount / budget_month.total_days).to_f.round(2)
    end

    def remaining_per_day
      (remaining / budget_month.days_remaining).to_f.round(2)
    end

    def remaining_per_week
      (remaining_per_day * 7).to_f.round(2)
    end

    def budgeted_per_week
      @budgeted_per_week ||= (budgeted_per_day * 7).to_f.round(2)
    end

    def budget_month
      @budget_month ||=
        begin
          mon, year = month.split('|')
          BudgetMonth.new(month: mon, year: year)
        end
    end
  end
end
