class AccountsApi < Sinatra::Base
  before do
    set_account!
    content_type 'application/json'
    @template = AccountTemplate.new(@account)
  end

  get '/' do
    @template.index
  end

  get '/:id' do
    @template.show
  end

  def set_account!
    if env['PATH_INFO'].match(/^\/(\d+)/)
      id = env['PATH_INFO'].match(/^\/(\d+)/)
      @account = Account.find_by_id(id[1])
    end
  end
end
