class ItemsApi < Sinatra::Base
  register Sinatra::Namespace
  include SharedHelpers

  get '/' do
    render_collection(Budget::Item.active.search_order(budget_month.piped))
  end

  post '/' do
    item.save ? render_new(item) : render_error(400, item.errors.join('; '))
  end

  get '/active' do
    render_collection(Budget::Amount.active(budget_month.piped))
  end

  namespace %r{/(?<item_id>\d+)} do
    get '' do
      item.to_json
    end

    put '' do
      if item.update_attributes(update_params)
        render_updated(item.to_hash)
      else
        render_error(400)
      end
    end

    post '/amount' do
      amount.save ? render_new(amount) : render_error(400)
    end

    put %r{/amount/(?<amount_id>\d+)/?} do
      if amount.update_attributes(amount_params)
        render_updated(amount.to_hash)
      else
        render_error(400)
      end
    end

    delete %r{/amount/(?<amount_id>\d+)/?} do
      if amount.destroy
        [200, {}.to_json]
      else
        render_error(400)
      end
    end

    get %r{/amounts/(?<amount_id>\d+)/transactions/?} do
      render_collection(amount.transactions)
    end
  end

  namespace '/amounts' do
    get '/monthly' do
      render_collection(Budget::MonthlyAmount.in(month.piped))
    end

    get '/weekly' do
      render_collection(Budget::WeeklyAmount.in(month.piped))
    end

    get '/discretionary' do
      [200, Discretionary.new(month).to_json]
    end
  end

  def amount_id
    params['amount_id']
  end

  def amount
    @amount ||= find_or_initialize_amount!
  end

  def amount_class
    return Budget::Amount unless month.piped == request_params['month']
    monthly? ? Budget::MonthlyAmount : Budget::WeeklyAmount
  end

  def month
    @month ||= BudgetMonth.new(month: params[:month], year: params[:year])
  end

  def find_or_initialize_amount!
    if amount_id.present?
      amount_class.find_by(id: amount_id, item_id: item_id) || render_404('budget amount', amount_id)
    else
      initialize_amount!
    end
  end

  def initialize_amount!
    if monthly?
      item.monthly_amounts.new(amount_params)
    else
      item.weekly_amounts.new(amount_params)
    end
  end

  def monthly?
    item.monthly?
  end

  def amount_params
    @amt_param ||= filtered_params(Budget::Amount)
  end

  def item_id
    params['item_id']
  end

  def item
    @item ||= find_or_create_item!
  end

  def find_or_create_item!
    if item_id.present?
      Budget::Item.find_by_id(item_id) || render_404('budget_item', item_id)
    else
      Budget::Item.new(create_params)
    end
  end

  def create_params
    require_parameters!('name', 'default_amount', 'monthly', 'expense')
    filtered_params(Budget::Item)
  end

  def update_params
    filtered_params(Budget::Item)
  end
end
