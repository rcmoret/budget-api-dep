class TransactionTemplate
  def initialize(account, **options)
    @account = account
    @options = options
    set_date_range!
  end

  def metadata
    @metadata ||= collect_metadata!
  end

  def collection
    @collection ||= collect_transactions!
  end

  private

  def set_date_range!
    @date_range = case
                  when @options[:date]
                    BudgetMonth.new(@options[:date]).date_range
                  when @options[:month]
                    BudgetMonth.new(@options).date_range
                  when @options[:first] && @options[:last]
                    (options[:first]..options[:last])
                  else
                    BudgetMonth.new.date_range
                  end
  end

  def collect_metadata!
    {
      date_range: [@date_range.first, @date_range.last],
      prior_balance: @account.transactions.prior_to(@date_range.first).total,
      query_options: @options.except(:first, :last, :month, :date)
    }
  end

  def collect_transactions!
    @account.transactions.between(@date_range, include_pending: true).as_collection
  end
end
