class BudgetItem < ActiveRecord::Base
  has_many :budgeted_amounts
  has_many :transactions, through: :budgeted_amounts

  scope :monthly,  -> { where(monthly: true) }
  scope :weekly,   -> { where(monthly: false) }
  scope :expenses, -> { where(expense: true) }
  scope :revenues, -> { where(expense: false) }

  PUBLIC_ATTRS = %w(id name expense monthly default_amount)

  def default_amount
    self[:default_amount].to_f
  end

  def revenue?
    !expense?
  end

  def to_json
    to_hash.to_json
  end

  def to_hash
    attributes.slice(*PUBLIC_ATTRS).merge('default_amount' => default_amount)
  end
end
