# frozen_string_literal: true

module Budget
  class ItemEvent < ActiveRecord::Base
    belongs_to :item, class_name: 'Item', foreign_key: :budget_item_id
    belongs_to :type, class_name: 'ItemEventType', foreign_key: :budget_item_event_type_id

    alias_attribute :type_id, :budget_item_event_type_id
    alias_attribute :item_id, :budget_item_id
  end
end
