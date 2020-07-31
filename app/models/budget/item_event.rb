# frozen_string_literal: true

module Budget
  class ItemEvent < ActiveRecord::Base
    belongs_to :item, class_name: 'Item', foreign_key: :budget_item_id
    belongs_to :type, class_name: 'ItemEventType', foreign_key: :budget_item_event_type_id

    alias_attribute :type_id, :budget_item_event_type_id
    alias_attribute :item_id, :budget_item_id

    validates :type_id, uniqueness: { scope: :item_id }, if: :item_create?
    validates :type_id, uniqueness: { scope: :item_id }, if: :item_delete?

    ItemEventType::VALID_TYPES.each do |event_type|
      scope event_type.to_sym, -> { where(type: ItemEventType.for(event_type)) }

      define_method "#{event_type}?" do
        type_id == ItemEventType.for(event_type).id
      end
    end

    def to_hash
      attributes
        .symbolize_keys
        .merge(budget_item_event_type: type.name)
    end
  end
end
