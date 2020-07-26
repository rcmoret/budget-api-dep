# frozen_string_literal: true

module Budget
  class ItemEvent < ActiveRecord::Base
    belongs_to :item, class_name: 'Item', foreign_key: :budget_item_id
    belongs_to :type, class_name: 'ItemEventType', foreign_key: :budget_item_event_type_id

    alias_attribute :type_id, :budget_item_event_type_id
    alias_attribute :item_id, :budget_item_id

    validates :item_id, uniqueness: { scoped: :type_id }, if: :item_create?

    ItemEventType::VALID_TYPES.each do |event_type|
      scope event_type.to_sym, -> { where(type: ItemEventType.for(event_type)) }

      define_method "#{event_type}?" do
        type_id == ItemEventType.for(event_type).id
      end
    end
  end
end
