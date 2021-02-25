# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
module API
  class Budget < Base
    register Sinatra::Namespace

    post '/items/events' do
      form = ::Budget::Events::Form.new(sym_params)
      if form.save
        render_new(form.attributes)
      else
        render_error(422, form.errors.to_hash)
      end
    end

    namespace '/categories' do
      get '' do
        render_collection(categories)
      end

      post '' do
        create_category!
        render_new(category)
      end

      namespace %r{/(?<category_id>\d+)} do
        get '' do
          [200, category.to_json]
        end

        get '/data' do
          hash = {
            category: category,
            events: category.events.in_range(date_range_params).includes(:item_view),
            item_views: category.item_views.in_range(date_range_params),
            transactions: category.transactions.in_range(date_range_params),
            date_range: date_range_params,
          }
          [200, hash.to_json]
        end

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
          namespace %r{/(?<item_id>\d+)} do
            get '' do
              [200, item.view.to_hash.to_json]
            end

            get '/transactions' do
              render_collection(item.transactions)
            end

            get '/events' do
              render_collection(item.events)
            end
          end
        end

        namespace '/maturity_intervals' do
          get '' do
            render_collection(category.maturity_intervals)
          end

          post '' do
            render_new(maturity_interval.to_hash)
          end

          namespace %r{/(?<maturity_interval_id>\d+)} do
            put '' do
              update_maturity_interval!
              render_updated(maturity_interval.to_hash)
            end

            delete '' do
              maturity_interval.destroy
              [204, {}]
            end
          end
        end
      end
    end

    get '/items' do
      [200, { metadata: metadata, collection: items }.to_json]
    end

    namespace '/discretionary' do
      get '/transactions' do
        render_collection(discretionary_transactions)
      end
    end

    private

    def item_id
      @item_id ||= params['item_id']
    end

    def item
      @item ||= ::Budget::Item.find_by(id: item_id, budget_category_id: category_id)
    rescue ActiveRecord::RecordNotFound
      render_404('budget_item', item_id)
    end

    def item_params
      @item_params ||= params_for(::Budget::Item)
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
      if category_id.present?
        ::Budget::Category.find(category_id)
      else
        ::Budget::Category.new(category_params)
      end
    end

    def create_category!
      return if category.save

      render_error(422, category.errors.to_hash)
    end

    def update_category!
      return if category.update(category_params)

      render_error(422, category.errors.to_hash)
    end

    def category_params
      @category_params ||= params_for(::Budget::Category)
    end

    def categories
      @categories ||= ::Budget::Category.active
    end

    def items
      @items ||= budget_interval.item_views.active
    end

    def metadata
      @metadata ||= ::Budget::Metadata.for(budget_interval)
    end

    def discretionary_transactions
      @discretionary_transactions ||= DiscretionaryTransactions.for(budget_interval).collection
    end

    def date_hash
      @date_hash ||= budget_interval.date_hash
    end

    def maturity_interval_id
      @maturity_interval_id ||= params[:maturity_interval_id]
    end

    def maturity_interval
      @maturity_interval ||= find_or_create_maturity_interval!
    end

    def find_or_create_maturity_interval!
      if maturity_interval_id
        category.maturity_intervals.find(maturity_interval_id)
      else
        ::Budget::CategoryMaturityInterval.find_or_create_by(
          interval: budget_interval,
          category: category
        )
      end
    end

    def update_maturity_interval!
      maturity_interval.update(interval: budget_interval)
    end

    def date_range_params
      @date_range_params ||= default_date_range.merge(params.fetch(:date_range, {}))
    end

    def default_date_range
      today = Time.current
      {
        beginning_month: (today.month == 12 ? 1 : today.month - 1),
        beginning_year: (today.month == 12 ? today.year : today.year - 1),
        ending_month: today.month,
        ending_year: today.year,
      }
    end
  end
end
# rubocop:enable Metrics/ClassLength
