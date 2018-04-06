class TransactionTemplate
  attr_reader :account, :options
  def initialize(account, **options)
    @account = account
    @options = options
  end

  delegate :to_json, to: :hash

  private

  def hash
    { account: account.to_hash, metadata: metadata, transactions: collection }
  end

  def metadata
    @metadata ||= {
      date_range: [date_range.first, date_range.last],
      prior_balance: account.transactions.prior_to(date_range.first).total,
      query_options: options,
    }
  end

  def collection
    @collection ||= account.transactions.between(
      date_range, include_pending: options[:include_pending]
    ).as_collection
  end

  def date_range
    @date_range ||= case
                    when options[:date]
                      BudgetMonth.new(options[:date]).date_range
                    when options[:month]
                      BudgetMonth.new(options).date_range
                    when options[:first] && options[:last]
                      (options[:first]..options[:last])
                    else
                      BudgetMonth.new.date_range
                    end
  end
end
