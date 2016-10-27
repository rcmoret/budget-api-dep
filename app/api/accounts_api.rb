class AccountsApi < Sinatra::Base
  register Sinatra::Namespace
  include SharedHelpers
  include Helpers::AccountApiHelpers

  get '/' do
    render_collection(Account.all)
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
      month, year = request_params.values_at('month', 'year')
      transaction_template = TransactionTemplate.new(account, month: month, year: year)
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
end
