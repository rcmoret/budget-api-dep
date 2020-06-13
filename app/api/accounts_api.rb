# frozen_string_literal: true

module API
  class Accounts < Base # rubocop:disable Metrics/ClassLength
    register Sinatra::Namespace

    get %r{/?} do
      render_collection(accounts)
    end

    post %r{/?} do
      create_account!
      render_new(account)
    end

    namespace %r{/(?<account_id>\d+)} do
      get '' do
        [200, account.to_json]
      end

      put '' do
        update_account!
        render_updated(account)
      end

      delete '' do
        account.destroy
        [204, {}]
      end

      namespace '/transactions' do
        get '' do
          [200, transaction_template.to_json]
        end

        post '' do
          create_transaction!
          render_new(transaction.view)
        end

        namespace %r{/(?<id>\d+)} do
          get '' do
            [200, transaction.view.to_json]
          end

          put '' do
            update_transaction!
            render_updated(transaction.view)
          end

          delete '' do
            if transaction.destroy
              [204, {}.to_json]
            else
              render_error(422, transaction.errors.to_hash)
            end
          end
        end
      end
    end

    not_found do
      msg = if body.include?('<h1>Not Found</h1>')
              "#{request.fullpath} is not a valid route"
            else
              body
            end
      status 404
      json(errors: msg)
    end

    private

    def account_id
      @account_id ||= params[:account_id]
    end

    def transaction_id
      @transaction_id ||= params[:id]
    end

    def account
      @account ||= find_or_build_account!
    end

    def find_or_build_account!
      account_id.present? ? Account.find(account_id) : Account.new(account_params)
    rescue ActiveRecord::RecordNotFound
      render_404('account', account_id)
    end

    def create_account!
      return if account.save

      render_error(422, account.errors.to_hash)
    end

    def update_account!
      return if account.update(account_params)

      render_error(422, account.errors.to_hash)
    end

    def account_params
      @account_params ||= params_for(Account)
    end

    def transaction
      @transaction ||= find_or_build_transaction!
    rescue ActiveRecord::RecordNotFound
      render_404('transaction', transaction_id)
    end

    def create_transaction!
      transaction.save!
    rescue ActiveRecord::RecordInvalid
      render_error(422, transaction.errors.to_hash)
    end

    def update_transaction!
      transaction.update!(transaction_params)
    rescue ActiveRecord::RecordInvalid
      render_error(422, transaction.errors.to_hash)
    end

    def find_or_build_transaction!
      if transaction_id.present?
        account.transactions.find(transaction_id)
      else
        account.transactions.build(transaction_params)
      end
    end

    def transaction_params
      @transaction_params ||= params_for(Transaction::Entry)
    end

    def filtered_transaction_params
      params = request_params.slice(*Transaction::Entry::PUBLIC_ATTRS)
      return params if request_params['details_attributes'].blank?

      params['details_attributes'] =
        request_params['details_attributes'].map do |attrs|
          attrs.slice(*Transaction::Detail::PUBLIC_ATTRS)
        end
      params
    end

    def transaction_template
      @transaction_template ||=
        TransactionTemplate.new(
          account,
          sym_params.merge(include_pending: budget_interval.current?)
        )
    end

    def accounts
      @accounts ||= Account.active
    end
  end
end
