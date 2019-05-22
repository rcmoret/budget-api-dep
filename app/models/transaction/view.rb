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
        .deep_symbolize_keys
        .merge(subtransactions: subtransactions)
    end

    def subtransactions
      CONFIG.dig(:db_config, 'adapter') == 'sqlite3' ? JSON.parse(super) : super
    end
  end
end
