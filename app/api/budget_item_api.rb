class BudgetItemApi < Sinatra::Base
  include SharedHelpers

  get '/' do
    BudgetItem.all.map(&:to_hash).to_json
  end

  post '/' do
    if budget_item.save
      render_new(budget_item)
    else
      render_error(400)
    end
  end

  get '/:id' do
    budget_item.to_json
  end

  def item_id
    params['id']
  end

  def budget_item
    @item ||= find_or_create_item!
  end

  def find_or_create_item!
    if item_id.present?
      BudgetItem.find_by_id(item_id) || render_404('budget_item', item_id)
    else
      BudgetItem.new(create_params)
    end
  end

  def create_params
    require_parameters!('name', 'default_amount')
    params.slice(*BudgetItem::PUBLIC_ATTRS)
  end
end
