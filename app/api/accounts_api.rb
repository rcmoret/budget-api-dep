class AccountsApi < Sinatra::Base
  include Api::Helpers

  ACCOUNT_PARAMS = %w(name cash_flow health_savings_account)
  TRANSACTION_PARAMS = %w(description monthly_amount_id amount clearance_date tax_deduction receipt check_number notes subtransactions_attributes)

  before do
    get_account!
    get_template!
  end

  get '/' do
    @template.index
  end

  get '/:id' do
    @template.show
  end

  get '/:id/transactions' do
    @template.transactions_collection
  end

  post '/' do
    if @account.save
      render_new(@account.to_hash)
    else
      render_error(400)
    end
  end

  put '/:id' do
    if @account.update_attributes(update_params)
      render_updated(@account.to_hash)
    else
      render_error(400)
    end
  end

  post '/:id/transactions' do
    build_transaction!
    if @transaction.save
      render_new(@transaction.to_hash)
    else
      render_error(400)
    end
  end

  def get_template!
    return unless get_request?
    @template = AccountTemplate.new(@account)
  end

  def get_account!
    return @account = Account.new(create_params) if id.nil? && post_request?
    @account = id.nil? ? :index : Account.find_by_id(id)
    render_404('account', id) if @account.nil?
  end

  def create_params
    return whitelisted_filterd_params unless params['name'].blank?
    render_error(422, "Missing required paramater(s): 'name'")
  end

  def whitelisted_filterd_params
    params.slice(*ACCOUNT_PARAMS).reject { |k,v| v.blank? }
  end
  alias_method :update_params, :whitelisted_filterd_params

  def build_transaction!
    transaction_params = params.slice(*TRANSACTION_PARAMS)
    @transaction = @account.primary_transactions.new(transaction_params)
  end
end
