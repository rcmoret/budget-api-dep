# frozen_string_literal: true

module Budget
  class Metadata < SimpleDelegator
    def self.for(budget_interval = Budget::Interval.current)
      new(budget_interval).call
    end

    def initialize(budget_interval)
      @budget_interval = budget_interval
      super(budget_interval)
    end

    def call
      {
        month: month,
        year: year,
        is_set_up: set_up?,
        is_closed_out: closed_out?,
        days_remaining: days_remaining,
        total_days: total_days,
        spent: spent,
        balance: balance
      }
    end

    private

    attr_reader :budget_interval

    def spent
      @spent ||= DiscretionaryTransactions.for(self).total
    end

    def balance
      @balance ||= current? ? (available_cash + charged).to_i : 0
    end

    def available_cash
      @available_cash ||= Account.available_cash
    end

    def charged
      @charged ||= Transaction::DetailView
                   .budget_inclusions
                   .non_cash_flow
                   .between(
                     budget_interval.date_range,
                     include_pending: budget_interval.current?
                   ).sum(:amount)
    end
  end
end
