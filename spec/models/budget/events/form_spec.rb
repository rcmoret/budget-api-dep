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

  describe 'initializing the new event form objects' do
    context 'when providing a single item array that is valid' do
      it 'initializes a create item event form object' do
        params = { 'events' => [{ 'event_type' => valid_create_event }] }
        expect(Budget::Events::CreateItemForm)
          .to receive(:new)
          .with(params['events'].first.symbolize_keys)
          .and_return(OpenStruct.new(save: true))
        described_class.new(params).save
      end
    end
  end

  describe '#save' do
    context 'when not valid' do
      it 'returns false' do
        params = { 'events' => [{ 'event_type' => unregistered_event }] }
        form = described_class.new(params)
        expect(form.save).to be false
      end
    end

    context 'when valid and the form objects all save' do
      let(:form_double) { instance_double(Budget::Events::CreateItemForm, save: true) }
      let(:params) do
        { 'events' => [{ 'event_type' => valid_create_event }] }
      end

      before do
        allow(Budget::Events::CreateItemForm)
          .to receive(:new)
          .with(params['events'].first.symbolize_keys)
          .and_return(form_double)
      end

      it 'returns true' do
        form = described_class.new(params)
        expect(form.save).to be true
      end

      it 'calls save on the form objects' do
        form = described_class.new(params)
        expect(form_double).to receive(:save)
        form.save
      end
    end

    context 'when valid and one of the form objects has errors' do
      before do
        allow(Budget::Events::CreateItemForm)
          .to receive(:new)
          .with(params['events'].first.symbolize_keys)
          .and_call_original
      end
      let(:params) do
        { 'events' => [{ 'event_type' => valid_create_event }] }
      end

      it 'returns false' do
        form = described_class.new(params)
        expect(form.save).to be false
      end

      it 'calls surfaces the form object errors' do
        form = described_class.new(params)
        form.save
        expect(form.errors['create_item_form.0.category']).to include 'can\'t be blank'
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
