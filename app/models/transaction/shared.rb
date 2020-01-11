# frozen_string_literal: true

module Transaction
  module Scopes
    extend ActiveSupport::Concern
    included do
      scope :cleared, -> { where.not(clearance_date: nil) }
      scope :pending, -> { where(clearance_date: nil) }
      scope :prior_to, lambda { |date|
        cleared
          .where(%("#{table_name}".clearance_date < :date), date: date)
      }
      scope :in, ->(range) { where(clearance_date: range) }
      scope :between, lambda { |range, include_pending: false|
        include_pending ? self.in(range).or(pending) : self.in(range)
      }
      scope :budget_inclusions, -> { where(budget_exclusion: false) }
      scope :non_transfers, -> { where(transfer_id: nil) }
      scope :non_cash_flow, -> { joins(:account).merge(Account.non_cash_flow) }
    end
  end
end
