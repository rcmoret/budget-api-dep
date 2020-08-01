# frozen_string_literal: true

FactoryBot.define do
  factory :budget_item_event_type, class: 'Budget::ItemEventType' do
    name { Budget::EventTypes::VALID_ITEM_TYPES.sample }

    Budget::EventTypes::VALID_ITEM_TYPES.each do |event_type|
      trait event_type.to_sym do
        name { event_type }
      end
    end
  end
end
