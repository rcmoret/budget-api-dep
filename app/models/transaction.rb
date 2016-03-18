module View
  class Transaction < ActiveRecord::Base
    self.table_name = 'transaction_view'
    include Transactions::Base
    include Transactions::Queries

    def readonly?
      true
    end

    def to_hash
      attributes.symbolize_keys
    end
  end
end

module Base
  class Transaction < ActiveRecord::Base
    include Transactions::Queries
    include Transactions::Base
    belongs_to :monthly_amount
    has_one :budget_item, through: :monthly_amount
  end
end

module Primary
  class Transaction < Base::Transaction
    has_many :subtransactions, class_name: 'Sub::Transaction', foreign_key: :primary_transaction_id,
                               dependent: :destroy
    has_one :view, class_name: 'View::Transaction', foreign_key: :id
    accepts_nested_attributes_for :subtransactions
    default_scope do
      where(primary_transaction_id: nil).includes(:subtransactions)
    end
  end
end

module Sub
  class Transaction < Base::Transaction
    belongs_to :primary_transaction, class_name: 'Primary::Transaction'
    has_one :view, through: :primary_transaction
    default_scope do
      where.not(primary_transaction_id: nil)
    end
  end
end
