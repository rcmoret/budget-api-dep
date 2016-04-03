class BudgetItemApi < Sinatra::Base
  include SharedHelpers
  include Helpers::BudgetItemApiHelpers

  get '/' do
    BudgetItem.all.map(&:to_hash).to_json
  end

  post '/' do
    budget_item.save ? render_new(budget_item) : render_error(400)
  end

  get '/:id' do
    budget_item.to_json
  end

  put '/:id' do
    if budget_item.update_attributes(update_params)
      render_updated(budget_item.to_hash)
    else
      render_error(400)
    end
  end
end
