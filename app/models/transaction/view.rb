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
      attributes.deep_symbolize_keys
    end
  end
end
