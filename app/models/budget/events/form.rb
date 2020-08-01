# frozen_string_literal: true

module Budget
  module Events
    class Form
      class << self
        def applies?(event_type)
          applicable_event_types.include?(event_type)
        end

        def register!(klass)
          raise DuplicateEventTypeRegistrationError if (registered_event_types & klass.applicable_event_types).any?

          registered_event_types.concat(klass.applicable_event_types.uniq)
          registered_classes << klass
        end

        def registered_classes
          @registered_classes ||= []
        end

        protected

        def applicable_event_types
          raise NotImplementedError
        end

        def registered_event_types
          @registered_event_types ||= []
        end
      end

      DuplicateEventTypeRegistrationError = Class.new(StandardError)
    end
  end
end
