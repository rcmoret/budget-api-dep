# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Budget::Events::Form do
  describe 'validations' do
    context 'when providing a single item array that is valid' do
      it 'returns valid' do
        params = { 'events' => [{ 'event_type' => valid_create_event }] }
        form = described_class.new(params)
        expect(form).to be_valid
      end
    end

    context 'when providing a single item array that is invalid' do
      it 'returns not valid' do
        params = { 'events' => [{ 'event_type' => unregistered_event }] }
        form = described_class.new(params)
        expect(form).not_to be_valid
      end
    end
  end

  def unregistered_event
    'unregistered_event'
  end

  def valid_create_event
    Budget::Events::CreateItemForm::APPLICABLE_EVENT_TYPES.sample
  end
end
