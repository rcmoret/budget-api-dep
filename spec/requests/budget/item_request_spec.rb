require 'spec_helper'

RSpec.describe 'Budget Item request specs' do
  describe 'GET /budget/items' do # index
    let(:month) { Date.today.month }
    let(:rent) { FactoryBot.create(:monthly_expense, month: month) }
    let(:phone) { FactoryBot.create(:monthly_expense, month: month) }
    let!(:items) { Budget::ItemView.find(rent.id, phone.id) }
    before { FactoryBot.create(:weekly_expense) }
    let(:endpoint) { '/budget/items' }

    subject { get endpoint }

    it 'retuns a 200' do
      expect(subject.status).to be 200
    end

    it 'returns the items as JSON' do
      parsed_body = JSON.parse(subject.body).map { |hash| hash.except('created_at', 'updated_at') }
      expected = items.map(&:to_hash).map(&:stringify_keys).map { |hash| hash.except('created_at', 'updated_at') }
      expect(parsed_body).to eq expected
    end
  end

  describe 'GET /budget/items' do # index
    let(:month) { Date.today.month }
    let(:grocery) { FactoryBot.create(:weekly_expense, month: month) }
    let(:gas) { FactoryBot.create(:weekly_expense, month: month) }
    let!(:items) do
      [Budget::ItemView.find(grocery.id), Budget::ItemView.find(gas.id)]
    end
    before { FactoryBot.create(:monthly_expense) }
    let(:endpoint) { '/budget/items' }

    subject { get endpoint }

    it 'retuns a 200' do
      expect(subject.status).to be 200
    end

    it 'returns the items as JSON' do
      parsed_body = JSON.parse(subject.body).map { |hash| hash.except('created_at', 'updated_at') }
      expect(parsed_body).to eq items.map(&:to_hash).map(&:stringify_keys).map { |hash| hash.except('created_at', 'updated_at') }
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
