class AccountsApi < Sinatra::Base
  register Sinatra::Namespace
  include SharedHelpers
  include Helpers::AccountApiHelpers

  before do
    backup! if backup_out_of_date?
  end

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
      params = request_params.slice('month', 'year').reduce({}) { |memo, (k,v)| memo.merge(k.to_sym => v) }
      include_pending = BudgetMonth.new(params).current?
      transaction_template = TransactionTemplate.new(account, params.merge(include_pending: include_pending))
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
      update_params = filtered_params(Primary::Transaction)
      if transaction.update_attributes(update_params)
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

  def backup_out_of_date?
    return true unless File.exists?('./db/dumps/current')
    24.hours.ago > File.mtime('./db/dumps/current')
  end

  def backup!
    Rake.application['pg:dump'].invoke
  end
end
