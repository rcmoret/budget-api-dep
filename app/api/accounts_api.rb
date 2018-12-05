class AccountsApi < Sinatra::Base
  register Sinatra::Namespace
  include SharedHelpers

  get %r{/?} do
    render_collection(accounts)
  end

  post %r{/?} do
    if account.save
      render_new(account.to_hash)
    else
      render_error(422, account.errors.to_hash)
    end
  end

  namespace %r{/(?<account_id>\d+)} do
    get '' do
      [200, account.to_hash.to_json]
    end

    put '' do
      if account.update_attributes(update_params)
        render_updated(account.to_hash)
      else
        render_error(400, account.errors.to_hash)
      end
    end

    delete '' do
      if account.destroy
        [204, {}]
      else
        render_error(400, account.errors.to_hash)
      end
    end

    get '/selectable_months' do
      render_collection(selectable_months)
    end

    get '/transactions' do
      [200, transaction_template.to_json]
    end

    post '/transactions' do
      if transaction.save
        render_new(transaction.to_hash)
      else
        render_error(400, transaction.errors.to_hash)
      end
    end

    put %r{/transactions/(?<id>\d+)} do
      if transaction.update(params_for(Primary::Transaction))
        render_updated(transaction.to_hash)
      else
        render_error(400, transaction.errors.to_hash)
      end
    end

    delete %r{/transactions/(?<id>\d+)} do
      if transaction.destroy
        [204, {}.to_json]
      else
        render_error(400, transaction.errors.to_hash)
      end
    end
  end

  not_found do
    msg = if body.include?('<h1>Not Found</h1>')
            "#{request.fullpath} is not a valid route"
          else
            body
          end
    status 404
    json({ errors: msg })
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
    account_id.present? ? Account.find(account_id) : Account.new(create_params)
  rescue ActiveRecord::RecordNotFound
    render_404('account', account_id)
  end

  def create_params
    params_for(Account)
  end
  alias :update_params :create_params

  def transaction
    @transaction ||= find_or_build_transaction!
  end

  def find_or_build_transaction!
    transaction = account.primary_transactions.find_or_initialize_by(id: transaction_id)
    return transaction if transaction.persisted?
    transaction.assign_attributes(params_for(Primary::Transaction))
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
    return params if request_params['subtransactions_attributes'].blank?
    params['subtransactions_attributes'] = request_params['subtransactions_attributes'].map do |attrs|
      attrs.slice(*Sub::Transaction::PUBLIC_ATTRS)
    end
    params
  end

  def transaction_template
    @transaction_template ||=
      TransactionTemplate.new(account, sym_params.merge(include_pending: budget_month.current?))
  end

  def accounts
    @accounts ||= Account.active.by_priority
  end
end
