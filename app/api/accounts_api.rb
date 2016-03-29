class AccountsApi < Sinatra::Base
  include Api::Helpers

  ACCOUNT_PARAMS = %w(name cash_flow health_savings_account)

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

  def validate_create_params!
    render_422 if ['name'].blank?
  end

  def get_template!
    @template = AccountTemplate.new(@account)
  end

  def get_account!
    if resource_should_be_found?
      @account = id.nil? ? :index : Account.find_by_id(id)
      render_404('account', id) if @account.nil?
    elsif post_request?
      @account = Account.new(create_params)
    end
  end

  def whitelisted_filterd_params
    params.slice(*ACCOUNT_PARAMS).reject { |k,v| v.blank? }
  end

  def create_params
    require_parameters!('name')
    whitelisted_filterd_params
  end

  alias_method :update_params, :whitelisted_filterd_params
end
