# frozen_string_literal: true

module Budget
  class ItemView < ActiveRecord::Base
    include Budget::Shared

    self.primary_key = :id

    def to_hash
      attributes.symbolize_keys
    end

    def readonly?
      true
    end
  end
end
