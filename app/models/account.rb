# frozen_string_literal: true

class Account < ActiveRecord::Base
  include Slugable

  has_many :transaction_views, class_name: 'Transaction::EntryView'
  has_many :transactions, class_name: 'Transaction::Entry'
  has_many :details,
           class_name: 'Transaction::Detail',
           through: :transactions
  has_many :detail_views, class_name: 'Transaction::DetailView'
  scope :active, -> { where(archived_at: nil) }
  scope :by_priority, -> { order('priority asc') }
  scope :cash_flow, -> { where(cash_flow: true) }
  scope :non_cash_flow, -> { where(cash_flow: false) }
  scope :details_prior_to, lambda { |date, include_pending:|
    details = Transaction::Detail.all

    if include_pending
      joins(:details)
        .merge(details.prior_to(date).or(details.pending))
    else
      joins(:details).merge(details.prior_to(date))
    end
  }
  validates_uniqueness_of :name, :priority, :slug, conditions: -> { active }
  validates_presence_of :name, :priority, :slug
  validates :slug, format: { with: /\A[a-z0-9-]+\Z/, message: SLUG_FORMAT_MESSAGE }

  PUBLIC_ATTRS = %w[name cash_flow priority slug].freeze

  class << self
    def available_cash
      cash_flow.joins(:details).sum(:amount)
    end
  end

  delegate :to_json, to: :to_hash

  def to_hash
    attributes
      .symbolize_keys
      .merge(balance: balance)
  end

  def balance_prior_to(date, include_pending:)
    self
      .class
      .where(id: id)
      .details_prior_to(date, include_pending: include_pending)
      .sum(:amount)
  end

  def deleted?
    archived_at.present?
  end

  def destroy
    transactions.any? ? update(archived_at: Time.current) : super
  end

  def to_s
    name
  end

  private

  def balance
    details.total
  end
end
