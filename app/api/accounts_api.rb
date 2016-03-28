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

  def get_template!
    @template = AccountTemplate.new(@account)
  end

  def get_account!
    @account = id.nil? ? :index : Account.find_by_id(id)
    render_404('account', id) if @account.nil?
  end
end
