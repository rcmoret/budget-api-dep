# frozen_string_literal: true

module Budget
  class ItemEventType < ActiveRecord::Base
    include EventTypes

    validates :name,
              uniqueness: true,
              inclusion: { in: VALID_ITEM_TYPES }

    VALID_ITEM_TYPES.each do |event_type|
      define_singleton_method event_type.to_sym do
        self.for(event_type)
      end
    end

    def self.for(type_name)
      find_or_create_by!(name: type_name.to_s)
    end
  end
end
