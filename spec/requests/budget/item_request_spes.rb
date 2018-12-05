require 'spec_helper'

RSpec.describe 'Budget Item request specs' do
  describe 'GET /budget/monthly_items' do # index
    let(:month) { Date.today.month }
    let(:rent) { FactoryBot.create(:monthly_expense, month: month) }
    let(:phone) { FactoryBot.create(:monthly_expense, month: month) }
    let!(:items) { [rent, phone] }
    before { FactoryBot.create(:weekly_expense) }
    let(:endpoint) { '/budget/monthly_items' }

    subject { get endpoint }

    it 'retuns a 200' do
      expect(subject.status).to be 200
    end

    it 'returns the items as JSON' do
      parsed_body = JSON.parse(subject.body)
      expect(parsed_body).to eq items.map(&:to_hash).map(&:stringify_keys)
    end
  end

  describe 'GET /budget/weekly_items' do # index
    let(:month) { Date.today.month }
    let(:grocery) { FactoryBot.create(:weekly_expense, month: month) }
    let(:gas) { FactoryBot.create(:weekly_expense, month: month) }
    let!(:items) do
      [Budget::WeeklyItem.find(grocery.id), Budget::WeeklyItem.find(gas.id)]
    end
    before { FactoryBot.create(:monthly_expense) }
    let(:endpoint) { '/budget/weekly_items' }

    subject { get endpoint }

    it 'retuns a 200' do
      expect(subject.status).to be 200
    end

    it 'returns the items as JSON' do
      parsed_body = JSON.parse(subject.body)
      expect(parsed_body).to eq items.map(&:to_hash).map(&:stringify_keys)
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
      it 'returns a 400' do
        expect(subject.status).to be 400
      end
    end
  end

  describe 'GET /budget/categories/:category_id/items/:item_id/transactions' do
    let(:item) { FactoryBot.create(:budget_item) }
    let(:category) { item.category }
    let!(:transaction) { FactoryBot.create(:subtransaction, budget_item: item) }
    let(:expected_transactions) { [Transaction::Record.find(transaction.id)].to_json }
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
