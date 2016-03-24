module Transactions
  module Base
    extend ActiveSupport::Concern
    included do
      belongs_to :account
      self.table_name ||= 'transactions'
    end

    def amount
      self[:amount].to_f
    end
  end
end

module Transactions
  module Queries
    extend ActiveSupport::Concern
    included do
      scope :between, -> (first, last, include_pending: false) do
        if include_pending
          where { clearance_date.in(first.to_date..last.to_date) | clearance_date.eq(nil) }
        else
          where { clearance_date.in(first.to_date..last.to_date) }
        end
      end
    end
  end
end
