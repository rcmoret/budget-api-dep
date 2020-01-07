# frozen_string_literal: true

module Transaction
  class DetailView < ActiveRecord::Base
    include Scopes

    self.table_name = :transaction_detail_view
    self.primary_key = :id

    belongs_to :account

    scope :discretionary, -> { where(budget_item_id: nil) }

    def self.total
      sum(:amount)
    end

    def to_hash
      attributes.symbolize_keys
    end
  end
end
