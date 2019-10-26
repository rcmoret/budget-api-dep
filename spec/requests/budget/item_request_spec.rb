# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Budget Item request specs' do
  # index
  describe 'GET /budget/items' do
    subject { get endpoint }

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
      let(:endpoint) { '/budget/items' }
      it 'retuns a 200' do
        expect(subject.status).to be 200
      end

      it 'returns a collection of items as JSON' do
        parsed_body = JSON.parse(subject.body)
        expected = items.map(&:reload).map(&:to_hash).map(&:stringify_keys)
        expect(parsed_body).to eq expected
      end
    end

    describe 'GET /budget/items/metadata' do # /metadata
      let(:endpoint) { '/budget/items/metadata' }

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
        expect(parsed_body).to eq expected_metadata
      end
    end
  end

  describe 'POST /budget/categories/:category_id/items' do
    let(:month) { (1..12).to_a.sample }
    let(:year) { (2000..2088).to_a.sample }
    let(:category) { FactoryBot.create(:category, :revenue) }
    let(:endpoint) { "/budget/categories/#{category.id}/items" }
    let(:body) { { amount: (100..900).to_a.sample } }
    subject { post endpoint, body }

    it 'returns a 201' do
      expect(subject.status).to be 201
    end

    it 'creates a record' do
      expect { subject }.to change { Budget::Item.count }.by(+1)
    end
  end

  describe 'PUT /budget/categories/:category_id/items/:item_id' do
    let(:month) { (1..12).to_a.sample }
    let(:year) { (2000..2088).to_a.sample }
    let(:item) { FactoryBot.create(:monthly_expense, amount: amount) }
    let(:category) { item.category }
    let(:endpoint) { "/budget/categories/#{category.id}/items/#{item.id}" }
    let(:amount) { (-900..-100).to_a.sample }
    let(:body) { { amount: (amount * 2) } }
    subject { put endpoint, body }

    it 'returns a 200' do
      expect(subject.status).to be 200
    end

    it 'updates the record' do
      expect { subject }.to(change { item.reload.amount })
    end
  end

  describe 'DELETE /budget/categories/:category_id/items/:item_id' do
    let!(:item) { FactoryBot.create(:budget_item) }
    let(:category) { item.category }
    let(:endpoint) { "/budget/categories/#{category.id}/items/#{item.id}" }

    subject { delete endpoint }

    context 'no transactions' do
      it 'returns a 204' do
        expect(subject.status).to be 204
      end

      it 'hard deletes the record' do
        expect { subject }.to change { Budget::Item.count }.by(-1)
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
