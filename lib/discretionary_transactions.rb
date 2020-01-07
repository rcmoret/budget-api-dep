# frozen_string_literal: true

class DiscretionaryTransactions
  attr_reader :budget_interval

  def self.for(budget_interval = Budget::Interval.current)
    new(budget_interval)
  end

  def initialize(budget_interval)
    @budget_interval = budget_interval
  end

  delegate :current?, :date_hash, :date_range, :days_remaining, :total_days,
           to: :budget_interval

  def collection
    @collection ||=
      Transaction::DetailView
      .discretionary
      .non_transfers
      .between(date_range, include_pending: current?)
  end

  def total
    collection.total.to_i
  end

  private

  def balance
    @balance ||= current? ? (available_cash + charged) : 0
  end

  def available_cash
    Account.available_cash.to_i
  end

  def charged
    Transaction::DetailView
      .budget_inclusions
      .non_transfers
      .non_cash_flow
      .between(date_range, include_pending: current?)
      .total
  end
end
