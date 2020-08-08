# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Budget Item request specs' do
  before { allow(Secret).to receive(:key).and_return('') }

  # index
  describe 'GET /budget/items' do
    subject { get '/budget/items' }

    let(:today) { Date.today }
    let(:month) { today.month }
    let(:year) { today.year }
    let(:budget_interval) do
      FactoryBot.build(:budget_interval, month: month, year: year)
    end
    let(:rent) do
      FactoryBot.create(:monthly_expense, interval: budget_interval)
    end
    let(:phone) do
      FactoryBot.create(:monthly_expense, interval: budget_interval)
    end
    let(:grocery) do
      FactoryBot.create(:weekly_expense, interval: budget_interval)
    end
    let!(:items) { Budget::ItemView.find(rent.id, phone.id, grocery.id) }
    let(:balance) { Account.available_cash.to_i }

    let!(:misc_expense) do
      FactoryBot.create(:transaction_entry, :discretionary, clearance_date: today)
    end

    describe 'GET /budget/items' do # index
      it 'retuns a 200' do
        expect(subject.status).to be 200
      end

      it 'returns some metadata' do
        parsed_body = JSON.parse(subject.body)
        expected_metadata = {
          'balance' => balance,
          'days_remaining' => budget_interval.days_remaining,
          'month' => budget_interval.month,
          'spent' => misc_expense.details.map(&:amount).reduce(:+),
          'total_days' => budget_interval.total_days,
          'year' => budget_interval.year,
          'is_set_up' => budget_interval.set_up?,
          'is_closed_out' => budget_interval.closed_out?,
        }
        expect(parsed_body['metadata']).to eq expected_metadata
      end

      it 'returns a collection of items as JSON' do
        parsed_body = JSON.parse(subject.body)
        expected = items.map(&:reload).map(&:to_hash).map(&:stringify_keys)
        expect(parsed_body['collection']).to eq expected
      end
    end
  end

  describe 'POST /budget/items/events - item create' do
    let(:month) { (1..12).to_a.sample }
    let(:year) { (2000..2088).to_a.sample }
    let(:category) { FactoryBot.create(:category, :revenue) }
    let(:endpoint) { '/budget/items/events' }
    let(:body) do
      {
        events: [
          {
            amount: (100..900).to_a.sample,
            budget_category_id: category.id,
            event_type: Budget::Events::CreateItemForm::ITEM_CREATE,
            month: month,
            year: year,
          },
        ],
      }
    end

    subject { post endpoint, body }

    it 'returns a 201' do
      expect(subject.status).to be 201
    end

    it 'creates an event' do
      expect { subject }.to(change { Budget::ItemEvent.count }.by(+1))
    end

    it 'creates a record' do
      expect { subject }.to change { Budget::Item.count }.by(+1)
    end
  end

  describe 'POST /budget/items/events -- item adjust' do
    before { FactoryBot.create(:budget_item_event, :item_create, item: item, amount: amount) }
    let(:month) { (1..12).to_a.sample }
    let(:year) { (2000..2088).to_a.sample }
    let(:item) { FactoryBot.create(:monthly_expense) }
    let(:endpoint) { '/budget/items/events' }
    let(:amount) { (-900..-100).to_a.sample }
    let(:body) do
      {
        events: [
          {
            event_type: Budget::EventTypes::ITEM_ADJUST,
            budget_item_id: item.id,
            amount: (amount * 2),
          },
        ],
      }
    end
    subject { post endpoint, body }

    it 'returns a 201' do
      expect(subject.status).to be 201
    end

    it 'updates the record' do
      expect { subject }.to(change { item.view.reload.amount }.from(amount).to(amount * 2))
    end

    it 'creates an item_adjust record' do
      expect { subject }.to(change { Budget::ItemEvent.item_adjust.count }.by(+1))
    end
  end

  describe 'POST /budget/item/events - item delete' do
    before { FactoryBot.create(:budget_item_event, :item_create, item: item, amount: item.amount) }
    let(:item) { FactoryBot.create(:budget_item) }
    let(:endpoint) { '/budget/items/events' }
    let(:body) do
      {
        events: [
          {
            event_type: Budget::EventTypes::ITEM_DELETE,
            budget_item_id: item.id,
          },
        ],
      }
    end

    subject { post endpoint, body }

    context 'no transactions' do
      before { travel_to Time.current }
      after { travel_back }

      it 'returns a 201' do
        expect(subject.status).to be 201
      end

      it 'updates deleted_at of the record' do
        expect { subject }.to(change { item.reload.deleted_at }.from(nil).to(Time.current))
      end

      it 'records an item delete record' do
        expect { subject }
          .to change { Budget::ItemEvent.item_delete.where(item: item).count }
          .from(0)
          .to(+1)
      end
    end

    context 'transactions exist' do
      before do
        FactoryBot.create(
          :transaction_entry,
          details_attributes: [
            {
              budget_item: item,
              amount: -10_000,
            },
          ]
        )
      end

      it 'returns a 422' do
        expect(subject.status).to be 422
      end
    end
  end

  describe 'GET /budget/categories/:category_id/items/:item_id/transactions' do
    subject { get endpoint }

    let(:item) { FactoryBot.create(:budget_item) }
    let(:category) { item.category }
    let!(:transaction) do
      FactoryBot.create(
        :transaction_entry,
        details_attributes: [
          {
            budget_item: item,
            amount: -100,
          },
        ]
      )
    end
    let(:detail_id) { transaction.details.first.id }
    let(:expected_transactions) do
      [Transaction::DetailView.find(detail_id).to_hash].to_json
    end
    let(:endpoint) do
      "/budget/categories/#{category.id}/items/#{item.id}/transactions"
    end

    it 'returns a 200' do
      expect(subject.status).to be 200
    end

    it 'returns the transactions as JSON' do
      expect(subject.body).to eq expected_transactions
    end
  end
end
