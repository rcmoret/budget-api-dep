module Budget
  class Category < ActiveRecord::Base
    has_many :items, foreign_key: :budget_category_id
    has_many :transactions, through: :items
    belongs_to :icon

    validates :default_amount, presence: true
    validates :default_amount, numericality: { less_than_or_equal_to: 0 }, if: :expense?
    validates :default_amount, numericality: { greater_than_or_equal_to: 0 }, if: :revenue?
    validates :name, uniqueness: true, presence: true

    scope :active, -> { where(archived_at: nil) }
    scope :monthly, -> { where(monthly: true) }
    scope :weekly, -> { where(monthly: false) }
    scope :expenses, -> { where(expense: true) }
    scope :revenues, -> { where(expense: false) }

    delegate :to_json, to: :to_hash
    delegate :class_name, :name, to: :icon, prefix: true, allow_nil: true

    PUBLIC_ATTRS = %w(id name expense monthly default_amount icon_id)

    def revenue?
      !expense?
    end

    def weekly?
      !monthly?
    end

    def to_hash
      attributes.slice(*PUBLIC_ATTRS).symbolize_keys.merge(icon_class_name: icon_class_name)
    end

    def archived?
      archived_at.present?
    end

    def archive!
      update(archived_at: Time.now)
    end

    def unarchive!
      update(archived_at: nil)
    end

    def destroy
      items.any? ? archive! : super
    end
  end
end
