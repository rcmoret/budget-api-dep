# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Budget::Events::FormBase do
  describe '.registered_classes' do
    it 'includes the item create form' do
      expect(described_class.send(:registered_classes)).to include Budget::Events::CreateItemForm
    end

    # it 'includes other forms'
  end

  describe '.applies?' do
    it 'raises a not implemented error' do
      expect { described_class.applies?('foo_bar_biz') }
        .to raise_error(NotImplementedError)
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

      it 'adds the event type the registry' do
        expect { described_class.register!(klass) }
          .to change { described_class.send(:registered_event_types) }
          .from(Budget::Events::CreateItemForm::APPLICABLE_EVENT_TYPES)
          .to([*Budget::Events::CreateItemForm::APPLICABLE_EVENT_TYPES, *klass.applicable_event_types])
          .and change { described_class.send(:registered_classes) }
          .from([Budget::Events::CreateItemForm])
          .to([Budget::Events::CreateItemForm, TestForm])
      end
    end
  end
end
