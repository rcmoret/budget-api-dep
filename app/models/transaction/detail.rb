# frozen_string_literal: true

module Transaction
  class Detail < ActiveRecord::Base
    belongs_to :budget_item, class_name: 'Budget::Item'
    belongs_to :entry,
               required: true,
               foreign_key: :transaction_entry_id
    validates :amount, presence: true
  end
end
