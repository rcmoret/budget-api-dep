class BudgetApi < Sinatra::Base
  register Sinatra::Namespace
  include SharedHelpers

  namespace '/categories' do
    get '' do
      render_collection(categories)
    end

    post '' do
      if category.save
        render_new(category)
      else
        render_error(400, category.errors.to_hash)
      end
    end

    namespace %r{/(?<category_id>\d+)} do
      put '' do
        if category.update(category_params)
          render_updated(category.to_hash)
        else
          render_error(400, category.errors.to_hash)
        end
      end

      delete '' do
        if category.destroy
          [204, {}]
        else
          render_error(400, category.errors.to_hash)
        end
      end

      namespace '/items' do
        post '' do
          item.save ? render_new(item) : render_error(400, item.errors.to_hash)
        end

        namespace %r{/(?<item_id>\d+)} do
          put '' do
            if item.update(item_params)
              render_updated(item.to_hash)
            else
              render_error(400, item.errors.to_hash)
            end
          end

          delete '' do
            render_error(400, "Item with id: #{item.id} could not be deleted") unless item.deletable?
            item.destroy
            [204, {}]
          end

          get '/transactions' do
            render_collection(item.transactions)
          end
        end
      end
    end
  end

  get '/monthly_items' do
    render_collection(monthly_items)
  end

  get '/weekly_items' do
    render_collection(weekly_items)
  end

  namespace '/discretionary' do
    get '' do
      [200, discretionary.to_json]
    end

    get '/transactions' do
      render_collection(discretionary.transactions)
    end
  end

  get '/selectable' do
    render_collection(selectable_items)
  end

  private

  def item_id
    @item_id ||= params['item_id']
  end

  def item
    @item ||= find_or_initialize_item!
  rescue ActiveRecord::RecordNotFound
    render_404('budget_item', item_id)
  end

  def find_or_initialize_item!
    if item_id.present?
      Budget::Item.find_by(id: item_id, budget_category_id: category_id)
    else
      category.items.new(item_params)
    end
  end

  def item_params
    @item_param ||= params_for(Budget::Item)
  end

  def category_id
    @category_id ||= params['category_id']
  end

  def category
    @category ||= find_or_build_category!
  rescue ActiveRecord::RecordNotFound
    render_404('budget_category', category_id)
  end

  def find_or_build_category!
    category_id.present? ? Budget::Category.find_by_id(category_id) : Budget::Category.new(category_params)
  end

  def category_params
    @category_params ||= params_for(Budget::Category)
  end

  def categories
    @categories ||= Budget::Category.active
  end

  def monthly_items
    @monthly_items ||= Budget::MonthlyItem.in(date_hash)
  end

  def weekly_items
    @weekly_items ||= Budget::WeeklyItem.in(date_hash)
  end

  def budget_month
    @budget_month ||= BudgetMonth.new(params)
  end

  def discretionary
    @discretionary ||= Discretionary.new(budget_month)
  end

  def seletable_items
    @selectable_items ||= [*weekly_items, *monthly_item.pending].sort(&:name)
  end

  def date_hash
    @date_hash ||= budget_month.date_hash
  end
end
