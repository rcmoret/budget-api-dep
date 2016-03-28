class AccountTemplate
  def initialize(account)
    @account = account
  end

  def index
    Account.all.map(&:to_hash).to_json
  end

  def show
    @account.to_hash.to_json
  end

  def transactions_collection
    {
      account: @account.to_hash,
      metadata: transaction_template.metadata,
      transactions: transaction_template.collection
    }.to_json
  end

  private

  def transaction_template
    @transction_template ||= TransactionTemplate.new(@account)
  end
end
