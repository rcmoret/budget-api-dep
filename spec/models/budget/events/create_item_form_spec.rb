# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Budget::Events::CreateItemForm do
  describe 'event type validation' do
    context 'when a valid event' do
      it 'is a valid form object' do
        event_type = described_class::APPLICABLE_EVENT_TYPES.sample
        form = new_object(event_type: event_type)
        expect(form).to be_valid
      end
    end

    context 'when an invalid event' do
      it 'is an invalid form object' do
        event_type = 'nonsense_event'
        form = new_object(event_type: event_type)
        expect(form).to_not be_valid
      end

      it 'has a meaningful error' do
        event_type = 'nonsense_event'
        form = new_object(event_type: event_type)
        form.valid?
        expect(form.errors['event_type'])
          .to include 'is not included in the list'
      end
    end
  end

  describe 'amount validation' do
    context 'when a integer' do
      it 'is a valid form object' do
        form = new_object(amount: 0)
        expect(form).to be_valid
      end
    end

    context 'when a float' do
      it 'is an invalid form object' do
        form = new_object(amount: 0.4)
        expect(form).to_not be_valid
      end

      it 'has a meaningful error message' do
        form = new_object(amount: 0.4)
        form.valid?
        expect(form.errors['amount']).to include 'must be an integer'
      end
    end
  end

  describe 'save' do
    context 'when the happy path' do
      it 'returns true' do
        form = new_object
        expect(form.save).to be true
      end

      it 'creates an interval if needed' do
        form = new_object(month: 1, year: 2017)
        expect { form.save }
          .to change { Budget::Interval.count }
          .by(+1)
      end

      it 'creates an event' do
        form = new_object(event_type: described_class::ITEM_CREATE)
        expect { form.save }
          .to change { Budget::ItemEvent.item_create.count }
          .by(+1)
      end

      it 'creates an item' do
        form = new_object
        expect { form.save }
          .to change { Budget::Item.count }
          .by(+1)
      end

      context 'when the event type is specified as setup item create' do
        it 'creates an event' do
          form = new_object(event_type: described_class::SETUP_ITEM_CREATE)
          expect { form.save }
            .to change { Budget::ItemEvent.setup_item_create.count }
            .by(+1)
        end
      end

      context 'when the event type is specified as pre setup item create' do
        it 'creates an event' do
          budget_interval(traits: [])
          form = new_object(event_type: described_class::ITEM_CREATE)
          expect { form.save }
            .to change { Budget::ItemEvent.pre_setup_item_create.count }
            .by(+1)
        end
      end
    end

    context 'when budget category lookup returns nothing' do
      it 'returns false' do
        form = new_object(budget_category_id: nil)
        expect(form.save).to be false
      end

      it 'includes a meaningful error message' do
        form = new_object(budget_category_id: nil)
        form.valid?
        expect(form.errors['category']).to include 'can\'t be blank'
      end
    end

    context 'when creating an invalid weekly item' do
      it 'returns false' do
        category = budget_category(:expense, :weekly)
        item = FactoryBot.create(:budget_item, category: category)
        interval = item.interval
        form = new_object(
          amount: -22_50,
          budget_category_id: category.id,
          month: interval.month,
          year: interval.year
        )
        expect(form.save).to be false
      end

      it 'contains an error message' do
        category = budget_category(:expense, :weekly)
        item = FactoryBot.create(:budget_item, category: category)
        interval = item.interval
        form = new_object(
          amount: -22_50,
          budget_category_id: category.id,
          month: interval.month,
          year: interval.year
        )
        form.save
        expect(form.errors['budget_category_id']).to include 'has already been taken'
      end
    end

    context 'when creating an invalid revenue item' do
      it 'returns false' do
        category = budget_category(:revenue)
        form = new_object(amount: -22_50, budget_category_id: category.id)
        expect(form.save).to be false
      end

      it 'contains an error message' do
        category = budget_category(:revenue)
        form = new_object(amount: -22_50, budget_category_id: category.id)
        form.valid?
        expect(form.errors['amount']).to include 'must be greater than or equal to 0'
      end
    end

    context 'when creating an invalid expense item' do
      it 'returns false' do
        category = budget_category(:expense)
        form = new_object(amount: 22_50, budget_category_id: category.id)
        expect(form.save).to be false
      end

      it 'contains an error message' do
        category = budget_category(:expense)
        form = new_object(amount: 22_50, budget_category_id: category.id)
        form.valid?
        expect(form.errors['amount']).to include 'must be less than or equal to 0'
      end
    end

    context 'when errors on the interval' do
      it 'returns false' do
        form = new_object(month: 0)
        expect(form.save).to be false
      end

      it 'does not create an interval object' do
        form = new_object(month: 0)
        expect { form.save }.to_not(change { Budget::Interval.count })
      end

      it 'has a meaningful error message' do
        form = new_object(month: 0)
        form.save
        expect(form.errors['month']).to include 'is not included in the list'
      end
    end
  end

  def today
    @today ||= Time.current
  end

  def new_params
    {
      amount: amount,
      budget_category_id: budget_category.id,
      event_type: described_class::APPLICABLE_EVENT_TYPES.sample,
      month: budget_interval.month,
      year: budget_interval.year,
    }
  end

  def new_object(**overrides)
    described_class.new(new_params.merge(overrides))
  end

  def budget_category(*traits, **overrides)
    FactoryBot.create(:category, *traits, **overrides)
  end

  def budget_interval(**params)
    @budget_interval ||= begin
       month = params.fetch(:month) { rand(1..12) }
       year = params.fetch(:year) { rand(2019..2025) }
       traits = params.fetch(:traits, [:set_up])
       FactoryBot.create(:budget_interval, *traits, month: month, year: year)
     end
  end

  def amount
    r = rand(100_00)
    budget_category.expense? ? (r * -1) : r
  end
end
