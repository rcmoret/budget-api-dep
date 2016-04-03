class ItemsApi < Sinatra::Base
  register Sinatra::Namespace
  include SharedHelpers
  include Helpers::ItemsApiHelpers

  get '/' do
    Budget::Item.all.map(&:to_hash).to_json
  end

  post '/' do
    budget_item.save ? render_new(budget_item) : render_error(400)
  end

  namespace %r{/(?<item_id>\d+)} do
    get '' do
      budget_item.to_json
    end

    put '' do
      if budget_item.update_attributes(update_params)
        render_updated(budget_item.to_hash)
      else
        render_error(400)
      end
    end

    post '/amount' do
      amount.save ? render_new(amount) : render_error(400)
    end

    def amount
      @amount ||= budget_item.amounts.new(amount_params)
    end

    def amount_params
      filtered_params(*%w(amount month))
    end
  end
end
