module Transaction
  class View < ActiveRecord::Base
    include SharedMethods
    include Scopes

    self.table_name = :transaction_view
    self.primary_key = :id

    def readonly?
      true
    end

    def to_hash
      attributes
        .merge(subtransactions: subtransactions)
        .deep_symbolize_keys
    end

    def subtransactions
      return JSON.parse(super) if CONFIG.dig(:db_config, 'adapter') == 'sqlite3'
      super
    end
  end
end
