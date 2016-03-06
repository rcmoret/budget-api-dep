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
    module ClassMethods
      def between(first_date, last_date, include_pending: false)
        if include_pending
          where{ (clearance_date.in(first_date..last_date) | clearance_date.eq(nil)) }
        else
          where(clearance_date: (first_date..last_date))
        end
      end
    end
  end
end
