module Transaction
  module SharedMethods
    extend ActiveSupport::Concern
    included do
      belongs_to :account
      alias to_hash :attributes
    end

    def description
      if self[:description].present?
        self[:description]
      elsif budget_amount
        budget_amount.name
      else
        ''
      end
    end

    def amount
      self[:amount].to_f unless self[:amount].nil?
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
        sum(:amount).to_f.round(2)
      end

      def as_collection
        all.map(&:to_hash)
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

    def attributes
      super.symbolize_keys.merge(amount: amount, subtransactions_attributes: sub_attrs)
    end

    def sub_attrs
      subtransactions_attributes.each_with_object({}) { |attrs, hash| hash[attrs['id']] = attrs }
    end
  end

  class Record < ActiveRecord::Base
    include Transaction::SharedMethods
    self.table_name = 'transactions'
    belongs_to :budget_amount, foreign_key: :monthly_amount_id, class_name: 'Budget::Amount'
    has_one :item, through: :budget_amount, class_name: 'Budget::Item'
    validates :account, presence: true
    scope :pending_last, -> { order('clearance_date IS NULL') }
    scope :by_clearnce_date, -> { order(clearance_date: :asc) }
    scope :ordered,  -> { pending_last.by_clearnce_date }
    delegate :name, to: :account, prefix: true

    def attributes
      super.symbolize_keys.merge(amount: amount, description: description, account: account_name)
    end
  end
end

module Sub
  class Transaction < Transaction::Record
    belongs_to :primary_transaction, class_name: 'Primary::Transaction'
    has_one :view, through: :primary_transaction
    validates :amount, presence: true

    PUBLIC_ATTRS = %w(id description monthly_amount_id amount account_id clearance_date).freeze

    default_scope do
      where.not(primary_transaction_id: nil)
    end
  end
end

module Primary
  class Transaction < Transaction::Record
    include ::Transaction::Scopes
    has_many :subtransactions, class_name: 'Sub::Transaction', foreign_key: :primary_transaction_id,
                               dependent: :destroy
    has_one :view, class_name: 'Transaction::View', foreign_key: :id
    validates :amount, presence: true, unless: :has_subtransactions?
    validates :amount, absence: true, if: :has_subtransactions?
    before_validation :set_amount_to_nil!, :set_monthly_amount_id!, :update_subtransactions!, if: :has_subtransactions?
    accepts_nested_attributes_for :subtransactions

    delegate :to_hash, to: :view

    WHITELISTED_ATTRS = %w(description monthly_amount_id amount
                           clearance_date tax_deduction receipt notes
                           check_number subtransactions_attributes).freeze

    PUBLIC_ATTRS = (
      WHITELISTED_ATTRS.dup << { 'subtransactions_attributes' => Sub::Transaction::PUBLIC_ATTRS }
                   ).freeze

    default_scope do
      where(primary_transaction_id: nil).includes(:subtransactions)
    end

    scope :pending, -> { where(clearance_date: nil) }

    def has_subtransactions?
      subtransactions.any?
    end

    private

    def update_subtransactions!
      subtransactions.each do |sub|
        sub.account_id = account_id
        sub.clearance_date = clearance_date
      end
    end

    def set_amount_to_nil!
      self[:amount] = nil
    end

    def set_monthly_amount_id!
      self[:monthly_amount_id] = nil
    end
  end
end
