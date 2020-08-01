# frozen_string_literal: true

FactoryBot.define do
  factory :budget_item_event, class: 'Budget::ItemEvent' do
    association :type, factory: :budget_item_event_type
    association :item, factory: :budget_item

    Budget::EventTypes::VALID_ITEM_TYPES.map(&:to_sym).each do |event_type|
      trait event_type do
        association :type, factory: [:budget_item_event_type, event_type]
      end
    end
  end
end
