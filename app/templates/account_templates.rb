class AccountTemplate
  def initialize(account = nil)
    @account = account
  end

  def index
    Account.all.map(&:to_hash).to_json
  end

  def show
    return not_found if @account.nil?
    @account.to_hash.to_json
  end

  private

  def not_found
    [404, { error: 'Resource not found' }.to_json]
  end
end
