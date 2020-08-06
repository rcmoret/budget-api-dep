# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Budget::Events::AdjustItemForm do
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

    describe 'amount validation' do
      context 'when a float' do
        it 'is an invalid form object' do
          form = build_form(amount: 0.4)
          expect(form).to_not be_valid
        end

        it 'has a meaningful error message' do
          form = build_form(amount: 0.4)
          form.valid?
          expect(form.errors['amount']).to include 'must be an integer'
        end
      end

      context 'when the item category is a revenue' do
        context 'when the amount is positive' do
          it 'is valid' do
            budget_item(:revenue)
            form = build_form(amount: 129_50)
            expect(form).to be_valid
          end
        end

        context 'when the amount is negative' do
          it 'is not valid' do
            budget_item(:revenue)
            form = build_form(amount: -129_50)
            expect(form).not_to be_valid
          end

          it 'provides an error message' do
            budget_item(:revenue)
            form = build_form(amount: -129_50)
            form.valid?
            expect(form.errors['amount']).to include 'must be greater than or equal to 0'
          end
        end
      end

      context 'when the item category is an expense' do
        context 'when the amount is negative' do
          it 'is valid' do
            budget_item(:expense)
            form = build_form(amount: -32_09)
            expect(form).to be_valid
          end
        end

        context 'when the amount is positive' do
          it 'is not valid' do
            budget_item(:expense)
            form = build_form(amount: 32_09)
            expect(form).not_to be_valid
          end
        end
      end
    end
  end

  describe '.save' do
    describe 'creates an event' do
      it 'adds an adjustment event' do
        form = build_form(event_type: 'item_adjust')
        expect { form.save }.to(change { Budget::ItemEvent.item_adjust.count }.from(0).to(+1))
      end

      it 'returns true' do
        form = build_form(event_type: 'item_adjust')
        expect(form.save).to be true
      end
    end

    describe 'pre-save validations' do
      context 'when invalid' do
        it 'returns false' do
          form = build_form(amount: -9.33)
          expect(form.save).to be false
        end
      end
    end

    describe 'the new event' do
      context 'when it is a valid event' do
        before { stub_new_event! }

        context 'when increasing an expense' do
          it 'calls new with the correct args' do
            stub_item_view(id: budget_item.id, amount: -22_89, expense: true)
            form = build_form(amount: -32_89)
            expect(Budget::ItemEvent)
              .to receive(:new)
              .with(hash_including(item_id: budget_item.id, amount: -10_00))
            form.save
          end
        end

        context 'when decreasing an expense' do
          it 'calls new with the correct args' do
            stub_item_view(id: budget_item.id, amount: -22_89, expense: true)
            form = build_form(amount: -15_89)
            expect(Budget::ItemEvent)
              .to receive(:new)
              .with(hash_including(item_id: budget_item.id, amount: 7_00))
            form.save
          end
        end

        context 'when increasing a revenue' do
          it 'calls new with the correct args' do
            stub_item_view(id: budget_item.id, amount: 22_89, expense: false)
            form = build_form(amount: 32_89)
            expect(Budget::ItemEvent)
              .to receive(:new)
              .with(hash_including(item_id: budget_item.id, amount: 10_00))
            form.save
          end
        end

        context 'when decreasing a revenue' do
          it 'calls new with the correct args' do
            stub_item_view(id: budget_item.id, amount: 22_89, expense: false)
            form = build_form(amount: 15_89)
            expect(Budget::ItemEvent)
              .to receive(:new)
              .with(hash_including(item_id: budget_item.id, amount: -7_00))
            form.save
          end
        end

        it 'calls save on the new event object' do
          stub_item_view(id: budget_item.id, amount: 22_89, expense: false)
          form = build_form(amount: 15_89)
          expect(event_double).to receive(:save)
          form.save
        end
      end
    end

    context 'when the event fails to save' do
      before { stub_new_event_with_errors! }

      it 'returns false' do
        form = build_form
        expect(form.save).to be false
      end

      it 'includes the event errors' do
        form = build_form
        form.save
        expect(form.errors['count']).to include 'cannot be greater than 0'
      end
    end
  end

  def budget_item(*traits, **attributes)
    @budget_item ||= FactoryBot.create(:budget_item, *traits, **attributes)
  end

  def default_form_params
    {
      budget_item_id: budget_item.id,
      event_type: described_class::APPLICABLE_EVENT_TYPES.sample,
      amount: 0,
    }
  end

  def build_form(**options)
    described_class.new(default_form_params.merge(options))
  end

  def event_double(**options)
    @event_double ||= instance_double(Budget::ItemEvent, save: true, **options)
  end

  def stub_new_event!
    allow(Budget::ItemEvent)
      .to receive(:new)
      .and_return(event_double)
  end

  def stub_new_event_with_errors!
    allow(Budget::ItemEvent)
      .to receive(:new)
      .and_return(event_double(save: false, errors: event_errors))
  end

  def stub_item_view(id:, amount:, expense:)
    allow(Budget::ItemView)
      .to receive(:find_by)
      .with(id: id)
      .and_return(item_view_double(id, amount, expense))
  end

  def item_view_double(id, amount, expense)
    # for some reason RSpec does not know about all of the instance methods
    # from the view for Budget::ItemView so I have to use an anonymous double
    double(
      id: id,
      amount: amount,
      expense?: expense,
      revenue?: !expense
    )
  end

  def event_errors
    event = instance_double(Budget::ItemEvent)
    @event_errors ||= ActiveModel::Errors.new(event).tap do |e|
      e.add(:count, 'cannot be greater than 0')
    end
  end
end
