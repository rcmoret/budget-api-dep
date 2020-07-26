# frozen_string_literal: true

module Budget
  class ItemEventType < ActiveRecord::Base
    VALID_TYPES = [
      ITEM_ADJUST = 'item_adjust',
      ITEM_CREATE = 'item_create',
      ITEM_DELETE = 'item_delete',
      LEGACY_ITEM_CREATE = 'legacy_item_create',
    ].freeze

    validates :name,
              uniqueness: true,
              inclusion: { in: VALID_TYPES }

    def self.for(type_name)
      find_or_create_by!(name: type_name.to_s)
    end
  end
end
