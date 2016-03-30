require 'spec_helper'

RSpec.describe 'AccountsApi /transactions/:id', type: :request do
  let(:checking) { FactoryGirl.create(:account, cash_flow: true, name: '1st Tenn') }
  let(:endpoint) { "/accounts/#{checking.id}/transactions" }
  describe 'transactions POST' do
    let(:response) { post endpoint, transaction_attributes }
    let(:status) { response.status }
    subject { JSON.parse(response.body) }
    context 'simple transaction' do
      let(:transaction_attributes) do
        { description: 'Kroger', amount: -60.0, clearance_date: '2015-01-04' }
      end
      it 'should return a 201' do
        expect(status).to be 201
      end
      it 'should create a new transaction' do
        expect { subject }.to change { Primary::Transaction.count }.by 1
      end
      include_examples 'JSON transaction'
    end
    context 'transaction with subs' do
      let(:subtransactions_attributes) do
        [ { description: 'Clothes', amount: -20.0 },
          { description: 'Food', amount: -35.0 } ]
      end
      let(:transaction_attributes) do
        { description: 'Costco', amount: '',
          subtransactions_attributes: subtransactions_attributes }
      end
      let(:response) { post endpoint, transaction_attributes }
      it { expect(response.status).to be 201 }
      include_examples 'JSON transaction with subtransactions'
    end
  end
  describe 'transactions POST' do
    let(:attrs) { { account: checking, description: 'Kroger', amount: -20.5 } }
    let(:update_attributes) { { clearance_date: '2015-03-14' } }
    let(:transaction_attributes) { attrs.merge(update_attributes) }
    let(:transaction) { FactoryGirl.create(:transaction, attrs) }
    let(:endpoint) { super() + "/#{transaction.id}" }
    context 'simple transaction' do
      let(:response) { put endpoint, update_attributes }
      subject { JSON.parse(response.body) }
      it { expect(response.status).to be 200 }
      include_examples 'JSON transaction'
    end
  end
end
