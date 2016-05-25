require 'spec_helper'

RSpec.describe 'AccountsApi', type: :request do
  let(:checking) { FactoryGirl.create(:account, cash_flow: true, name: '1st Tenn') }
  let(:savings) { FactoryGirl.create(:account, cash_flow: false, name: 'Savings') }
  let!(:accounts) { [checking, savings].map(&:to_hash) }
  describe 'GET routes' do
    subject { get endpoint }
    let(:body) { subject.body }
    describe '/accounts (index)' do
      let(:endpoint) { 'accounts/' }
      it 'should call #all on Account model' do
        expect(Account).to receive(:all) { accounts }
        subject
      end
      it 'should return the accounts as JSON' do
        expect(body).to eq accounts.to_json
      end
    end
    describe '/accounts/:id (show)' do
      context 'id of an existing account' do
        let(:endpoint) { "/accounts/#{checking.id}" }
        it 'should return that account as JSON' do
          expect(body).to eq checking.to_hash.to_json
        end
      end
      context 'random id' do
        let(:endpoint) { "/accounts/#{checking.id}404"}
        let(:error) do
          { error: "Could not find a(n) account with id: #{checking.id}404" }.to_json
        end
        it 'should return a 404' do
          expect(subject.status).to be 404
        end
        it 'should have an error message' do
          expect(body).to eq error
        end
      end
    end
  end
  describe 'GET /accounts/:id/transactions' do
    let(:endpoint) { "/accounts/#{checking.id}/transactions" }
    let(:response) { get endpoint }
    let(:parsed_response) { JSON.parse(response.body) }
    it 'should return a JSON hash with 3 keys' do
      expect(parsed_response.keys).to eq ['account', 'metadata', 'transactions']
    end
    describe 'the account' do
      subject { parsed_response['account'] }
      include_examples 'a JSON account'
    end
    describe 'the metadata' do
      subject { parsed_response['metadata'] }
      include_examples 'account/transactions metadata JSON'
    end
    describe 'the transaction collection' do
      let(:transaction) { FactoryGirl.create(:transaction, account: checking).view }
      let!(:transaction_hash) do
        h = transaction.to_hash.merge(amount: transaction.amount.to_f).stringify_keys
        h.delete_if { |k, v| k == 'updated_at' }
      end
      subject { parsed_response['transactions'] }
      it { should be_a Array }
      it { expect(subject[0]).to include transaction_hash }
      it { expect(subject[0]['updated_at'].to_date).to eq transaction.updated_at.to_date }
    end
  end
  describe 'POST /accounts' do
    let(:endpoint) { '/accounts' }
    context 'valid params' do
      let(:body) { { name: checking.name } }
      let(:response) { post endpoint, body }
      it 'should create a new resource' do
        expect { response }.to change { Account.count }.by 1
      end
      subject { JSON.parse(response.body) }
      include_examples 'a JSON account'
    end
    context 'invalid params (lacking "name")' do
      let(:post_body) { { cash_flow: false } }
      let(:response) { post endpoint, post_body }
      let(:status) { response.status }
      let(:response_body) { JSON.parse(response.body) }
      it 'should return a 422 status' do
        expect(status).to be 422
      end
      it 'should have an error message' do
        expect(response_body['error']).to eq "Missing required paramater(s): 'name'"
      end
    end
  end
  describe 'PUT /accounts/:id' do
    let!(:account) { FactoryGirl.create(:account, cash_flow: true, name: checking.name) }
    let(:endpoint) { "/accounts/#{account.id}" }
    let(:request_body) { { cash_flow: false } }
    let(:response) { put endpoint, request_body }
    let(:request) { response }
    let(:status) { response.status }
    it 'should return a 200 and update the account' do
      expect(status).to be 200
    end
    it 'should update the account record' do
      expect { request }.to change { account.reload.cash_flow }
    end
    subject { JSON.parse(response.body) }
    include_examples 'a JSON account'
  end
end
