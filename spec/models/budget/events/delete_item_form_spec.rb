# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Budget::Events::DeleteItemForm do
  describe 'validations' do
    describe 'event type validation' do
      context 'when a valid event' do
        it 'is a valid form object' do
          event_type = described_class::APPLICABLE_EVENT_TYPES.sample
          form = build_form(event_type: event_type)
          expect(form).to be_valid
        end
      end

      context 'when an invalid event' do
        it 'is an invalid form object' do
          event_type = 'nonsense_event'
          form = build_form(event_type: event_type)
          expect(form).to_not be_valid
        end

        it 'has a meaningful error' do
          event_type = 'nonsense_event'
          form = build_form(event_type: event_type)
          form.valid?
          expect(form.errors['event_type'])
            .to include 'is not included in the list'
        end
      end
    end

    describe 'item validation' do
      context 'when a budget item exists' do
        it 'is a valid form object' do
          form = build_form(budget_item_id: budget_item.id)
          expect(form).to be_valid
        end
      end

      context 'when the budget item exists for the id passed' do
        it 'is an invalid form object' do
          form = build_form(budget_item_id: 0)
          expect(form).not_to be_valid
        end

        it 'returns a meaniful error message' do
          form = build_form(budget_item_id: 0)
          form.valid?
          expect(form.errors['budget_item']).to include 'can\'t be blank'
        end
      end
    end

    describe 'item transacations validations' do
      context 'when there are no transactions details' do
        it 'is a valid form object' do
          form = build_form
          expect(form).to be_valid
        end
      end

      context 'when there is a transaction detail associated' do
        before { FactoryBot.create(:transaction_detail, budget_item: budget_item) }

        it 'is an invalid form object' do
          form = build_form
          expect(form).to_not be_valid
        end

        it 'returns a meaningful error message' do
          form = build_form
          form.valid?
          expect(form.errors['budget_item']).to include 'cannot delete an item with transaction details'
        end
      end
    end
  end

  describe 'save' do
    before { travel_to Time.current }
    after { travel_back }

    context 'when the happy path' do
      it 'returns true' do
        form = build_form
        expect(form.save).to be true
      end

      it 'updates the deleted at timestamp' do
        form = build_form
        expect { form.save }
          .to(change { budget_item.reload.deleted_at }
          .from(nil)
          .to(Time.current))
      end

      it 'creates an event record' do
        form = build_form
        expect { form.save }.to(change { Budget::ItemEvent.item_delete.count }
          .from(0).to(+1))
      end
    end

    context 'when there are pre-save errors' do
      it 'returns false' do
        form = build_form(budget_item_id: 0)
        expect(form.save).to be false
      end

      it 'returns a meaningful error message' do
        form = build_form(budget_item_id: 0)
        form.save
        expect(form.errors['budget_item']).to include 'can\'t be blank'
      end
    end

    context 'when the underlying record has errors' do
      it 'returns false' do
        stub_item_find_by_with_error!
        form = build_form
        expect(form.save).to be false
      end

      it 'returns a meaningful error message' do
        stub_item_find_by_with_error!
        form = build_form
        form.save
        expect(form.errors['count']).to include 'cannot be greater than 0'
      end
    end
  end

  def default_form_params
    {
      budget_item_id: budget_item.id,
      event_type: described_class::ITEM_DELETE,
    }
  end

  def build_form(**options)
    described_class.new(default_form_params.merge(options))
  end

  def budget_item(*traits, **attributes)
    @budget_item ||= FactoryBot.create(:budget_item, *traits, **attributes)
  end

  def budget_item_double
    @budget_item_double ||= instance_double(Budget::Item, update: true, transaction_details: [], amount: 0)
  end

  def budget_item_error_double
    @budget_item_error_double ||= instance_double(Budget::Item,
                                                  update: false,
                                                  amount: 0,
                                                  transaction_details: [],
                                                  errors: item_errors)
  end

  def stub_item_find_by_with_error!
    allow(Budget::Item)
      .to receive(:find_by)
      .and_return(budget_item_error_double)
    allow(Budget::ItemEvent)
      .to receive(:new)
      .and_return(instance_double(Budget::ItemEvent, errors: []))
  end

  def item_errors
    @item_errors ||= ActiveModel::Errors.new(budget_item).tap do |e|
      e.add(:count, 'cannot be greater than 0')
    end
  end
end
