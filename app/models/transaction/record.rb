module Transaction
  class Record < ActiveRecord::Base
    include Scopes

    self.table_name = 'transactions'

    belongs_to :budget_item, class_name: 'Budget::Item'
    has_one :category, through: :budget_item, class_name: 'Budget::Category'

    validates :account, presence: true
    validates :budget_item_id, uniqueness: true, if: :budget_item_monthly?

    scope :pending_last, -> { order('clearance_date IS NULL') }
    scope :by_clearnce_date, -> { order(clearance_date: :asc) }
    scope :ordered,  -> { pending_last.by_clearnce_date }
    scope :search, -> (term) { where("description like '%#{term}%'") }

    delegate :name, to: :account, prefix: true
    delegate :to_json, to: :to_hash
    delegate :monthly?, to: :budget_item, allow_nil: true, prefix: true

    def readonly?
      true
    end

    def to_hash
      attributes.symbolize_keys.merge(account_name: account_name)
    end
  end
end
