class AccountsApi < Sinatra::Base
  include Api::Helpers

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

  def create_params
    require_parameters!('name')
    params.slice('name', 'cash_flow', 'health_savings_account').reject { |k,v| v.blank? }
  end
end
