class ItemsApi < Sinatra::Base
  register Sinatra::Namespace
  include SharedHelpers
  include Helpers::ItemsApiHelpers

  get '/' do
    render_collection(Budget::Item.all)
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
  end

  namespace '/amounts' do
    get '/monthly' do
      render_collection(Budget::MonthlyAmount.anticipated)
    end

    get '/weekly' do
      render_collection(Budget::WeeklyAmount.active)
    end
  end

  def amount_id
    params['amount_id']
  end

  def amount
    @amount ||= find_or_initialize_budget_amount!
  end

  def amount_class
    monthly? ? Budget::MonthlyAmount : Budget::WeeklyAmount
  end

  def find_or_initialize_budget_amount!
    if amount_id.present?
      amount_class.find_by_id(amount_id) || render_404('budget amount', amount_id)
    else
      initialize_amount!
    end
  end

  def initialize_amount!
    if monthly?
      budget_item.monthly_amounts.new(amount_params)
    else
      budget_item.weekly_amounts.new(amount_params)
    end
  end

  def monthly?
    budget_item.monthly?
  end

  def amount_params
    filtered_params(*%w(amount month))
  end
end
