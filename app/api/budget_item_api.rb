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

    put %r{/amount/(?<amount_id>\d+)} do
      if amount.update_attributes(amount_params)
        render_updated(amount.to_hash)
      else
        render_error(400)
      end
    end

    def amount_id
      params['amount_id']
    end

    def amount
      @amount ||= find_or_initialize_budget_amount!
    end

    def find_or_initialize_budget_amount!
      if amount_id.present?
        Budget::Amount.find_by_id(amount_id) || render_404('budget amount', amount_id)
      else
        budget_item.amounts.new(amount_params)
      end
    end

    def amount_params
      filtered_params(*%w(amount month))
    end
  end
end
