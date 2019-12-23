# frozen_string_literal: true

module Transaction
  class Entry < ActiveRecord::Base
    belongs_to :account, required: true
    has_many :details, foreign_key: :transaction_entry_id
  end
end
