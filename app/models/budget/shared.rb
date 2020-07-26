# frozen_string_literal: true

module Budget
  def self.table_name_prefix
    'budget_'
  end

  module Shared
    extend ActiveSupport::Concern

    included do
      has_many :transaction_details,
               class_name: 'Transaction::Detail',
               foreign_key: :budget_item_id
      has_many :transactions,
               class_name: 'Transaction::DetailView',
               foreign_key: :budget_item_id
      belongs_to :category, foreign_key: :budget_category_id
      belongs_to :interval,
                 class_name: 'Interval',
                 foreign_key: :budget_interval_id

      scope :in, lambda { |month:, year:|
        where(budget_interval_id: Interval.for(month: month, year: year).id)
      }
      scope :active, -> { where(deleted_at: nil) }
      scope :deleted, -> { where.not(deleted_at: nil) }

      validates :category, presence: true

      delegate :to_json, to: :to_hash
    end

    def to_hash # rubocop:disable Metrics/MethodLength
      {
        id: id,
        accural: accrual,
        amount: amount,
        budget_category_id: budget_category_id,
        budget_interval_id: interval.id,
        expense: expense?,
        icon_class_name: icon_class_name,
        month: interval.month,
        name: name,
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
      transaction_details.none?
    end
  end
end
