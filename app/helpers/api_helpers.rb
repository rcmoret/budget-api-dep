module Helpers
  module AccountApiHelpers
    ACCOUNT_PARAMS = %w(name cash_flow health_savings_account)
    TRANSACTION_PARAMS = %w(description monthly_amount_id amount clearance_date tax_deduction receipt check_number notes subtransactions_attributes)

    def account_id
      params['account_id']
    end

    def transaction_id
      params['id']
    end

    def account
      @account ||= find_or_build_account!
    end

    def find_or_build_account!
      if account_id.present?
        Account.find_by_id(account_id) || render_404('account', account_id)
      else
        Account.new(create_params)
      end
    end

    def create_params
      require_parameters!('name')
      filtered_params(*ACCOUNT_PARAMS)
    end

    def transaction
      @transaction ||= find_or_build_transaction!
    end

    def find_or_build_transaction!
      transaction = account.primary_transactions.find_or_initialize_by(id: transaction_id)
      return transaction if transaction.persisted?
      transaction.assign_attributes(filtered_params(*TRANSACTION_PARAMS))
      transaction
    end
  end

  module ItemsApiHelpers
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
      require_parameters!('name', 'default_amount')
      filtered_params(*Budget::Item::PUBLIC_ATTRS)
    end

    def update_params
      filtered_params(*Budget::Item::PUBLIC_ATTRS)
    end
  end
end
