module Transaction
  module SharedMethods
    extend ActiveSupport::Concern
    included do
      belongs_to :account
    end

    def amount
      self[:amount].to_f
    end
  end

  module Scopes
    extend ActiveSupport::Concern
    included do
      scope :cleared,  -> { where.not(clearance_date: nil) }
      scope :prior_to, -> (date) { cleared.where{ clearance_date < date } }
      scope :between,  -> (range, include_pending: false) do
        if include_pending
          where { clearance_date.in(range) | clearance_date.eq(nil) }
        else
          where { clearance_date.in(range) }
        end
      end
    end

    class_methods do
      def total
        sum(:amount).to_f
      end
    end
  end
end

module Transaction
  class View < ActiveRecord::Base
    self.table_name = 'transaction_view'
    include Transaction::SharedMethods
    include Transaction::Scopes

    def readonly?
      true
    end

    def to_hash
      attributes.symbolize_keys
    end
  end

  class Record < ActiveRecord::Base
    include Transaction::SharedMethods
    self.table_name = 'transactions'
    belongs_to :budgeted_amount, foreign_key: :monthly_amount_id
    has_one :budget_item, through: :budgeted_amount
  end
end

module Primary
  class Transaction < Transaction::Record
    include ::Transaction::Scopes
    has_many :subtransactions, class_name: 'Sub::Transaction', foreign_key: :primary_transaction_id,
                               dependent: :destroy
    has_one :view, class_name: 'Transaction::View', foreign_key: :id
    accepts_nested_attributes_for :subtransactions
    default_scope do
      where(primary_transaction_id: nil).includes(:subtransactions)
    end
  end
end

module Sub
  class Transaction < Transaction::Record
    belongs_to :primary_transaction, class_name: 'Primary::Transaction'
    has_one :view, through: :primary_transaction
    default_scope do
      where.not(primary_transaction_id: nil)
    end
  end
end
