module Transaction
  class View < ActiveRecord::Base
    include Scopes

    belongs_to :account
    belongs_to :transfer
    self.table_name = :transaction_view
    self.primary_key = :id

    def self.as_collection
      all.map(&:to_hash)
    end

    def readonly?
      true
    end

    def to_hash
      attributes
        .merge(details: details)
        .deep_symbolize_keys
    end

    def details
      return JSON.parse(super) if CONFIG.dig(:db_config, 'adapter') == 'sqlite3'

      super
    end
  end
end
