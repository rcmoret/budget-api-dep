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
        date_range = (first_date.to_date..last_date.to_date)
        if include_pending
          where { clearance_date.in(date_range) | clearance_date.eq(nil) }
        else
          where { clearance_date.in(date_range) }
        end
      end
    end
  end
end
