# frozen_string_literal: true

module Budget
  module Events
    class FormBase
      class << self
        def applies?(event_type)
          applicable_event_types.include?(event_type)
        end

        def handler_registered?(event_type)
          registered_event_types.include?(event_type)
        end

        def handler_gateway(event_type)
          handler = registered_classes.find { |potential_hanlder| potential_hanlder.applies?(event_type) }
          return handler unless handler.nil?

          raise MissingHandlerError, "no handler register for #{event_type}"
        end

        def register!(klass)
          raise DuplicateEventTypeRegistrationError if (registered_event_types & klass.applicable_event_types).any?

          registered_event_types.concat(klass.applicable_event_types.uniq)
          registered_classes << klass
        end

        protected

        def applicable_event_types
          raise NotImplementedError
        end

        def registered_event_types
          @registered_event_types ||= []
        end

        def registered_classes
          @registered_classes ||= []
        end
      end

      MissingHandlerError = Class.new(StandardError)
      DuplicateEventTypeRegistrationError = Class.new(StandardError)
    end
  end
end
