# frozen_string_literal: true

module Budget
  module EventTypes
    VALID_ITEM_TYPES = [
      ITEM_ADJUST = 'item_adjust',
      ITEM_CREATE = 'item_create',
      ITEM_DELETE = 'item_delete',
      LEGACY_ITEM_CREATE = 'legacy_item_create',
      PRE_SETUP_ITEM_CREATE = 'pre_setup_item_create',
      SETUP_ITEM_CREATE = 'setup_item_create',
    ].freeze
  end
end
