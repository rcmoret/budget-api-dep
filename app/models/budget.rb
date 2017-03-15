module Budget
  class Item < ActiveRecord::Base
    self.table_name = 'budget_items'
    has_many :amounts, foreign_key: :budget_item_id
    has_many :weekly_amounts, foreign_key: :budget_item_id
    has_many :monthly_amounts, foreign_key: :budget_item_id
    has_many :transactions, through: :amounts

    scope :monthly,  -> { where(monthly: true) }
    scope :weekly,   -> { where(monthly: false) }
    scope :expenses, -> { where(expense: true) }
    scope :revenues, -> { where(expense: false) }
    scope :search_order, -> (month=nil) {
      month ||= BudgetMonth.piped
      order(
        %Q{ (select count(*) from monthly_amounts where month = '#{month}' AND budget_item_id = "budget_items".id) = 0 DESC,
            (select count(*) from monthly_amounts where budget_item_id = "budget_items".id) DESC
        }
      )
    }

    PUBLIC_ATTRS = %w(id name expense monthly default_amount)

    def default_amount
      self[:default_amount].to_f
    end

    def revenue?
      !expense?
    end

    def to_json
      to_hash.to_json
    end

    def to_hash
      attributes.slice(*PUBLIC_ATTRS).merge('default_amount' => default_amount)
    end
  end

  class Amount < ActiveRecord::Base
    self.table_name = 'monthly_amounts'
    has_many :transactions, class_name: 'Transaction::Record', foreign_key: :monthly_amount_id

    belongs_to :item, class_name: 'Budget::Item', foreign_key: :budget_item_id
    validates :item, presence: true
    delegate :name, :default_amount, :expense?, :revenue?, to: :item

    validates :amount, numericality: { less_than_or_equal_to: 0 }, if: :expense?
    validates :amount, numericality: { greater_than_or_equal_to: 0 }, if: :revenue?

    before_validation :set_month!
    before_validation :set_default_amount!, if: 'amount.nil?'

    scope :current,  -> { where(month: BudgetMonth.piped) }
    scope :expenses, -> { joins(:item).merge(Budget::Item.expenses).order('amount ASC') }
    scope :revenues, -> { joins(:item).merge(Budget::Item.revenues).order('amount DESC') }
    scope :in, lambda   { |month=nil| month.nil? ? current : where(month: month) }
    scope :weekly,   -> { joins(:item).merge(Budget::Item.weekly) }
    scope :monthly,  -> { joins(:item).merge(Budget::Item.monthly) }

    alias_attribute :item_id, :budget_item_id

    PUBLIC_ATTRS = %w(amount month).freeze

    def self.discretionary(month)
      if month.current?
        (Account.available_cash + MonthlyAmount.current.remaining +
         WeeklyAmount.remaining + Account.charged).round(2)
      else
        self.in(month.piped).sum(:amount)
      end
    end

    def self.active(month = nil)
      WeeklyAmount.all + MonthlyAmount.in(month).anticipated
    end

    def item_id=(id)
      budget_item_id=(id)
    end

    def to_hash
      { id: id, name: name, amount: amount, remaining: remaining,
        month: month, item_id: item_id, deletable: deletable? }
    end

    def to_json
      to_hash.to_json
    end

    def amount
      self[:amount].to_f unless self[:amount].nil?
    end

    def remaining
      amount.to_f
    end

    def destroy
      return false if transactions.any?
      super
    end

    private

    def set_default_amount!
      self.amount = default_amount
    end

    def set_month!
      self.month ||= BudgetMonth.piped
    end

    def deletable?
      transactions.none?
    end
  end

  class MonthlyAmount < Amount

    default_scope { monthly }

    scope :anticipated, -> { joins("LEFT JOIN (#{::Transaction::Record.all.to_sql}) t " +
                             'ON t.monthly_amount_id = "monthly_amounts".id').where('t.id IS NULL') }

    def self.remaining
      anticipated.sum(:amount).to_f
    end

    def remaining
      transactions.any? ? 0 : amount.to_f
    end
  end

  class WeeklyAmount < Amount

    default_scope { current.weekly }

    def self.remaining
      all.inject(0) { |total, amount| total += amount.remaining }.to_f
    end

    def remaining
      expense? ? [difference, 0].min : [difference, 0].max
    end

    private

    def difference
      (amount - transactions.sum(:amount)).to_f.round(2)
    end
  end

  class Discretionary
    def self.to_hash(month)
      discretionary = Budget::Amount.discretionary(month)
      amount = month.current? ? [discretionary, 0].max : discretionary
      { id: 0, name: 'Discretionary', amount: amount, remaining: discretionary,
        month: month.piped, item_id: 0, days_remaining: month.days_remaining }
    end
  end
end
