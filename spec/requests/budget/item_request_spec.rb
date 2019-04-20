require 'spec_helper'

RSpec.describe 'Budget Item request specs' do
  describe 'GET /budget/items' do # index
    let(:today) { Date.today }
    let(:month) { today.month }
    let(:year) { today.year }
    let(:budget_month) { FactoryBot.build(:budget_month, month: month, year: year) }
    let(:rent) { FactoryBot.create(:monthly_expense, budget_month: budget_month) }
    let(:phone) { FactoryBot.create(:monthly_expense, budget_month: budget_month) }
    let(:grocery) { FactoryBot.create(:weekly_expense, budget_month: budget_month) }
    let!(:items) { Budget::ItemView.find(rent.id, phone.id, grocery.id) }
    let(:balance) { Account.available_cash.to_i }
    let(:spent) do
      Transaction::Record.between(budget_month.date_range, include_pending: budget_month.current?)
        .discretionary
        .sum(:amount)
        .to_i
    end
    before do
      FactoryBot.create(:transaction, budget_item: rent, amount: rent.amount, clearance_date: today)
    end
    let(:endpoint) { '/budget/items' }

    subject { get endpoint }

    describe 'GET /budget/items' do # index
      it 'retuns a 200' do
        expect(subject.status).to be 200
      end

      it 'returns some metadata' do
        parsed_body = JSON.parse(subject.body)
        expected_metadata = {
          'balance' => balance,
          'days_remaining' => budget_month.days_remaining,
          'month' => budget_month.month,
          'spent' => spent,
          'total_days' => budget_month.total_days,
          'year' => budget_month.year,
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

  describe 'POST /budget/categories/:category_id/items' do
    let(:month) { (1..12).to_a.sample }
    let(:year) { (2000..2088).to_a.sample }
    let(:category) { FactoryBot.create(:category, :revenue) }
    let(:endpoint) { "/budget/categories/#{category.id}/items" }
    let(:body) { { month: month, year: year, amount: (100..900).to_a.sample } }
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
      expect { subject }.to change { item.reload.amount }
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
      before { FactoryBot.create(:transaction, budget_item: item) }
      it 'returns a 422' do
        expect(subject.status).to be 422
      end
    end
  end

  describe 'GET /budget/categories/:category_id/items/:item_id/transactions' do
    let(:item) { FactoryBot.create(:budget_item) }
    let(:category) { item.category }
    let!(:transaction) { FactoryBot.create(:subtransaction, budget_item: item) }
    let(:expected_transactions) { [Transaction::Record.find(transaction.id).to_hash].to_json }
    let(:endpoint) do
      "/budget/categories/#{category.id}/items/#{item.id}/transactions"
    end

    subject { get endpoint }

    it 'returns a 200' do
      expect(subject.status).to be 200
    end

    it 'returns the transactions as JSON' do
      expect(subject.body).to eq expected_transactions
    end
  end
end
