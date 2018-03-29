class AccountsApi < Sinatra::Base
  register Sinatra::Namespace
  include SharedHelpers

  get '/' do
    render_collection(Account.active.by_priority)
  end

  post '/' do
    account.save ? render_new(account.to_hash) : render_error(400)
  end

  namespace %r{/(?<account_id>\d+)} do
    get '' do
      account.to_hash.to_json
    end

    put '' do
      if account.update_attributes(filtered_params(Account))
        render_updated(account.to_hash)
      else
        render_error(400)
      end
    end

    get '/selectable_months' do
      render_collection(selectable_months)
    end

    get '/transactions' do
      transaction_template.to_json
    end

    post '/transactions' do
      transaction.save ? render_new(transaction.to_hash) : render_error(400)
    end

    put %r{/transactions/(?<id>\d+)} do
      if transaction.update_attributes(filtered_params(Primary::Transaction))
        render_updated(transaction.to_hash)
      else
        render_error(400)
      end
    end

    delete %r{/transactions/(?<id>\d+)} do
      transaction.destroy ? [200, {}.to_json] : render_error(400)
    end
  end

  private

  def account_id
    @account_id ||= params[:account_id]
  end

  def transaction_id
    @transaction_id ||= params[:id]
  end

  def account
    @account ||= find_or_build_account!
  end

  def find_or_build_account!
    if account_id.present?
      Account.find_by_id(account_id) || render_404('account', account_id)
    else
      Account.new(create_params)
    end
  end

  def create_params
    require_parameters!('name')
    filtered_params(Account)
  end

  def transaction
    @transaction ||= find_or_build_transaction!
  end

  def find_or_build_transaction!
    transaction = account.primary_transactions.find_or_initialize_by(id: transaction_id)
    return transaction if transaction.persisted?
    transaction.assign_attributes(filtered_params(Primary::Transaction))
    transaction
  end

  def selectable_months
    beginning_date = account.oldest_clearance_date.to_month
    ending_date = [Date.today.next_month, account.newest_clearance_date].max.to_month
    (beginning_date..ending_date).to_a.reverse.map do |month|
      { string: month.strftime('%B, %Y'), value: "#{month.month}|#{month.year}" }
    end
  end

  def filtered_transaction_params
    params = request_params.slice(*Primary::Transaction::PUBLIC_ATTRS)
    if request_params['subtransactions_attributes'].blank?
      params['subtransactions_attributes'] = []
    else
      params['subtransactions_attributes'] = request_params['subtransactions_attributes'].map do |id, attrs|
        attrs.slice(*Sub::Transaction::PUBLIC_ATTRS)
      end
    end
    params
  end

  def transaction_template
    @transaction_template ||=
      TransactionTemplate.new(account, sym_params.merge(include_pending: budget_month.current?))
  end
end
