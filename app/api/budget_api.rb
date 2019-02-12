class BudgetApi < Sinatra::Base
  register Sinatra::Namespace
  include SharedHelpers

  namespace '/categories' do
    get '' do
      render_collection(categories)
    end

    post '' do
      create_category!
      render_new(category)
    end

    namespace %r{/(?<category_id>\d+)} do
      put '' do
        update_category!
        render_updated(category)
      end

      delete '' do
        if category.destroy
          [204, {}]
        else
          render_error(422, category.errors.to_hash)
        end
      end

      namespace '/items' do
        post '' do
          create_item!
          render_new(item)
        end

        namespace %r{/(?<item_id>\d+)} do
          put '' do
            update_item!
            render_updated(item)
          end

          delete '' do
            render_error(422, "Item with id: #{item.id} could not be deleted") unless item.deletable?
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

  get '/items' do
    [200, { metadata: discretionary, collection: items}.to_json]
  end

  namespace '/discretionary' do
    get '/transactions' do
      render_collection(discretionary.transactions)
    end
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

  def create_item!
    item.save!
  rescue ActiveRecord::RecordInvalid
    render_error(422, item.errors.to_hash)
  end

  def update_item!
    item.update!(item_params)
  rescue ActiveRecord::RecordInvalid
    render_error(422, item.errors.to_hash)
  end

  def item_params
    @item_params ||= params_for(Budget::Item)
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

  def create_category!
    category.save!
  rescue ActiveRecord::RecordInvalid
    render_error(422, category.errors.to_hash)
  end

  def update_category!
    category.update!(category_params)
  rescue ActiveRecord::RecordInvalid
    render_error(422, category.errors.to_hash)
  end

  def category_params
    @category_params ||= params_for(Budget::Category)
  end

  def categories
    @categories ||= Budget::Category.active
  end

  def items
    @items ||= Budget::ItemView.in(date_hash)
  end

  def budget_month
    @budget_month ||= BudgetMonth.new(params)
  end

  def discretionary
    @discretionary ||= Discretionary.new(budget_month)
  end

  def date_hash
    @date_hash ||= budget_month.date_hash
  end
end
