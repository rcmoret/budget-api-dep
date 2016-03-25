class AccountTemplate
  def initialize(account)
    @account = account
    return not_found if @account.nil?
  end

  def index
    Account.all.map(&:to_hash).to_json
  end

  def show
    @account.to_hash.to_json
  end

  def transactions_collection(**query_opts)
    transaction_template = TransactionTemplate.new(@account, query_opts)
    {
      account: @account.to_hash,
      metadata: transaction_template.metadata,
      transactions: transaction_template.collection
    }.to_json
  end

  private

  def not_found
    [404, { error: 'Resource not found' }.to_json]
  end
end
