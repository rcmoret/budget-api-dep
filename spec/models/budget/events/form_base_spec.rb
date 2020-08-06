# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Budget::Events::FormBase do
  describe '.registered_classes' do
    it 'includes the item adjust form' do
      expect(described_class.send(:registered_classes)).to include Budget::Events::AdjustItemForm
    end

    it 'includes the item create form' do
      expect(described_class.send(:registered_classes)).to include Budget::Events::CreateItemForm
    end

    it 'includes the item delete form' do
      expect(described_class.send(:registered_classes)).to include Budget::Events::DeleteItemForm
    end
  end

  describe '.applies?' do
    it 'raises a not implemented error' do
      expect { described_class.applies?('foo_bar_biz') }
        .to raise_error(NotImplementedError)
    end
  end

  describe '.handler_registered?' do
    context 'when providing one that is registered' do
      it 'returns true' do
        event_type = Budget::Events::CreateItemForm::APPLICABLE_EVENT_TYPES.sample
        expect(described_class.handler_registered?(event_type)).to be true
      end
    end

    context 'when providing one that is not registered' do
      it 'returns false' do
        event_type = 'unregistered_event'
        expect(described_class.handler_registered?(event_type)).to be false
      end
    end
  end

  describe 'handler_gateway' do
    context 'when a create event' do
      it 'returns the create event form object' do
        event_type = Budget::Events::CreateItemForm::APPLICABLE_EVENT_TYPES.sample
        expect(described_class.handler_gateway(event_type)).to eq Budget::Events::CreateItemForm
      end
    end

    context 'when an unregistered event' do
      it 'raises an error' do
        event_type = 'unregistered_event'
        expect { described_class.handler_gateway(event_type) }
          .to raise_error(described_class::MissingHandlerError)
      end
    end
  end

  describe '.register!' do
    context 'when registering a class w/ an event type that has been registered' do
      let(:klass) do
        class TestForm < described_class
          def self.applicable_event_types
            [Budget::Events::CreateItemForm::APPLICABLE_EVENT_TYPES.sample]
          end
        end

        TestForm
      end

      it 'raises an already registered error' do
        expect { described_class.register!(klass) }
          .to raise_error(described_class::DuplicateEventTypeRegistrationError)
      end
    end

    context 'whne registering a new class with distinct/unique event types' do
      let(:klass) do
        class TestForm < described_class
          APPLICABLE_EVENT_TYPES = [SecureRandom.uuid].freeze

          def self.applicable_event_types
            APPLICABLE_EVENT_TYPES
          end
        end

        TestForm
      end

      let(:event_classes) do
        [
          Budget::Events::AdjustItemForm,
          Budget::Events::CreateItemForm,
          Budget::Events::DeleteItemForm,
        ]
      end
      let(:event_types) do
        event_classes.flat_map { |klass| klass::APPLICABLE_EVENT_TYPES }
      end

      it 'adds the event type the registry' do
        expect { described_class.register!(klass) }
          .to change { described_class.send(:registered_event_types) }
          .from(event_types)
          .to([*event_types, *klass.applicable_event_types])
          .and change { described_class.send(:registered_classes) }
          .from(event_classes)
          .to([*event_classes, TestForm])
      end
    end
  end
end
