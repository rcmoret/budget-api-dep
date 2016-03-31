require 'sinatra/namespace'

class AccountsApi < Sinatra::Base
  register Sinatra::Namespace
  include Api::Helpers

  ACCOUNT_PARAMS = %w(name cash_flow health_savings_account)
  TRANSACTION_PARAMS = %w(description monthly_amount_id amount clearance_date tax_deduction receipt check_number notes subtransactions_attributes)

  get '/' do
    Account.all.map(&:to_hash).to_json
  end

  post '/' do
    account.save ? render_new(account.to_hash) : render_error(400)
  end

  namespace %r{/(?<account_id>\d+)} do
    get '' do
      account.to_hash.to_json
    end

    put '' do
      if account.update_attributes(update_params)
        render_updated(account.to_hash)
      else
        render_error(400)
      end
    end

    get '/transactions' do
      transaction_template = TransactionTemplate.new(account)
      {
        account: account.to_hash,
        metadata: transaction_template.metadata,
        transactions: transaction_template.collection
      }.to_json
    end

    post '/transactions' do
      transaction.save ? render_new(transaction.to_hash) : render_error(400)
    end

    put %r{/transactions/(?<id>\d+)} do
      if transaction.update_attributes(transaction_params)
        render_updated(transaction.to_hash)
      else
        render_error(400)
      end
    end
  end


  def account_id
    params['account_id']
  end

  def transaction_id
    params['id']
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
    return whitelisted_filterd_params unless params['name'].blank?
    render_error(422, "Missing required paramater(s): 'name'")
  end

  def transaction_params
    params.slice(*TRANSACTION_PARAMS).reject { |k,v| v.blank? }
  end

  def whitelisted_filterd_params
    params.slice(*ACCOUNT_PARAMS).reject { |k,v| v.blank? }
  end
  alias_method :update_params, :whitelisted_filterd_params

  def transaction
    @transaction ||= find_or_build_transaction!
  end

  def find_or_build_transaction!
    transaction = account.primary_transactions.find_or_initialize_by(id: transaction_id)
    return transaction if transaction.persisted?
    transaction.assign_attributes(transaction_params)
    transaction
  end
end
