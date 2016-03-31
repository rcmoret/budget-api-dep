require 'sinatra/namespace'

class AccountsApi < Sinatra::Base
  register Sinatra::Namespace
  include SharedHelpers
  include Helpers::AccountApiHelpers

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
end
