class Icon < ActiveRecord::Base
  validates :name, uniqueness: true, presence: true
  validates :class_name, uniqueness: true, presence: true

  has_many :budget_categories, class_name: 'Budget::Category', dependent: :nullify

  PUBLIC_ATTRS = %w[id class_name name].freeze

  delegate :to_hash, to: :attributes

  def attributes
    super.slice(*PUBLIC_ATTRS).symbolize_keys
  end
end
