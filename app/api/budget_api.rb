class ItemsApi < Sinatra::Base
  register Sinatra::Namespace
  include SharedHelpers
  include Helpers::ItemsApiHelpers

  get '/' do
    render_collection(Budget::Item.all)
  end

  post '/' do
    item.save ? render_new(item) : render_error(400)
  end

  get '/active' do
    render_collection(Budget::Amount.active)
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

    put %r{/amount/(?<amount_id>\d+)} do
      if amount.update_attributes(amount_params)
        render_updated(amount.to_hash)
      else
        render_error(400)
      end
    end
  end

  namespace '/amounts' do
    get %r{/(?<freq>monthly|weekly)/?} do
      month = BudgetMonth.new(month: params[:month], year: params[:year])
      render_collection(case [params['freq'], month.current?]
                        when ['monthly', true]
                          Budget::MonthlyAmount.anticipated
                        when ['weekly', true]
                          Budget::WeeklyAmount.all
                        when ['monthly', false]
                          Budget::Amount.monthly.in(month.piped)
                        when ['weekly', false]
                          Budget::Amount.weekly.in(month.piped)
                        end)
    end

    get '/discretionary' do
      month = BudgetMonth.new(month: params[:month], year: params[:year])
      [200, Budget::Discretionary.to_hash(month).to_json]
    end
  end

  def amount_id
    params['amount_id']
  end

  def amount
    @amount ||= find_or_initialize_amount!
  end

  def amount_class
    monthly? ? Budget::MonthlyAmount : Budget::WeeklyAmount
  end

  def find_or_initialize_amount!
    if amount_id.present?
      amount_class.find_by_id(amount_id) || render_404('budget amount', amount_id)
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
    filtered_params(Budget::Amount)
  end
end
