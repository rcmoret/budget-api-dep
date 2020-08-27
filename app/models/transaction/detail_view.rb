# frozen_string_literal: true

module Transaction
  class DetailView < ActiveRecord::Base
    include Scopes

    self.table_name = :transaction_detail_view
    self.primary_key = :id

    belongs_to :account
    belongs_to :budget_item, class_name: 'Budget::Item'

    scope :discretionary, -> { where(budget_item_id: nil) }
    scope :in_range, ->(range) { joins(:budget_item).merge(Budget::Item.in_range(range)) }

    def self.total
      sum(:amount)
    end

    def to_hash
      attributes.symbolize_keys
    end
  end
end
