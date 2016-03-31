class AccountTemplate
  def initialize(account)
    @account = account
  end

  def self.index
    Account.all.map(&:to_hash).to_json
  end

  def show
    @account.to_hash.to_json
  end

  def transactions_collection
  end

  private

  def transaction_template
    @transction_template ||= TransactionTemplate.new(@account)
  end
end
