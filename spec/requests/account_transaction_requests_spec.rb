require 'spec_helper'

RSpec.describe 'AccountsApi /transactions/:id', type: :request do
  let(:checking) { FactoryGirl.create(:account, cash_flow: true, name: '1st Tenn') }
  let(:endpoint) { "/accounts/#{checking.id}/transactions" }
  describe 'transactions POST' do
    let(:response) { post endpoint, post_body }
    let(:status) { response.status }
    subject { JSON.parse(response.body) }
    context 'simple transaction' do
      let(:post_body) do
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
      let(:post_body) do
        { description: 'Costco', amount: '',
          subtransactions_attributes:
          [
            { description: 'Clothes', amount: -20.0 },
            { description: 'Food', amount: -35.0 }
          ]
        }
      end
      let(:response) { post endpoint, post_body }
      it { expect(response.status).to be 201 }
    end
  end
end
