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

      scope :in, ->(query = BudgetMonth.date_hash) { where(query).includes(:category) }

      validates :category, presence: true

      delegate :to_json, to: :to_hash
    end

    def to_hash
      {
        id: id,
        name: name,
        amount: amount,
        category_id: budget_category_id,
        icon_class_name: icon_class_name,
        month: month,
        year: year,
        deletable: deletable?,
        expense: expense?,
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
