module Transaction
  module SharedMethods
    extend ActiveSupport::Concern
    included do
      belongs_to :account
      belongs_to :transfer
    end
  end

  module Scopes
    extend ActiveSupport::Concern
    included do
      scope :cleared, -> { where.not(clearance_date: nil) }
      scope :pending, -> { where('clearance_date IS NULL') }
      scope :prior_to, -> (date) { cleared.where("clearance_date < ?", date) }
      scope :in, -> (range) { where(clearance_date: range) }
      scope :between, -> (range, include_pending: false) {
        include_pending ? self.in(range).or(pending) : self.in(range)
      }
      scope :budget_inclusions, -> { where(budget_exclusion: false) }
      scope :discretionary, -> {
        budget_inclusions.non_transfers.where(budget_item_id: nil).where('amount IS NOT NULL')
      }
      scope :non_transfers, -> { where(transfer_id: nil) }
    end

    class_methods do
      def total
        sum(:amount).to_i
      end

      def as_collection
        all.map(&:to_hash)
      end
    end
  end
end
