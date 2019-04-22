module Budget

  def self.table_name_prefix
    'budget_'
  end

  module Shared
    extend ActiveSupport::Concern

    included do
      has_many :transactions, -> { includes(:account).ordered },
               class_name: 'Transaction::Record', foreign_key: :budget_item_id
      belongs_to :category, foreign_key: :budget_category_id
      belongs_to :interval, class_name: 'Interval', foreign_key: :budget_interval_id

      scope :in, ->(month:, year:) { where(budget_interval_id: Interval.for(month: month, year: year).id) }

      validates :category, presence: true

      delegate :to_json, to: :to_hash
    end

    def to_hash
      {
        id: id,
        name: name,
        amount: amount,
        budget_category_id: budget_category_id,
        icon_class_name: icon_class_name,
        expense: expense?,
        budget_interval_id: interval.id,
        month: interval.month,
        year: interval.year,
      }
    end

    def weekly?
      !monthly?
    end

    def revenue?
      !expense?
    end

    def deletable?
      transactions.none?
    end
  end
end
