# frozen_string_literal: true

module Budget
  class ItemEventType < ActiveRecord::Base
    include EventTypes

    validates :name,
              uniqueness: true,
              inclusion: { in: VALID_ITEM_TYPES }

    def self.for(type_name)
      find_or_create_by!(name: type_name.to_s)
    end
  end
end
