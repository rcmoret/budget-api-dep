module Budget
  class Metadata < SimpleDelegator
    def self.for(budget_interval = Budget::Interval.current)
      new(budget_interval).call
    end

    # def initialize(budget_interval)
    #   @budget_interval = budget_interval
    #   super(budget_interval)
    # end

    def call
      {
        month: month,
        year: year,
        is_set_up: set_up?,
        is_closed_out: closed_out?,
        days_remaining: days_remaining,
        total_days: total_days,
        spent: spent,
        balance: balance,
      }
    end

    private

    def spent
      @spent ||= DiscretionaryTransactions.for(self).total
    end

    def balance
      @balance ||= current? ? (Account.available_cash + Account.charged).to_i : 0
    end
  end
end
