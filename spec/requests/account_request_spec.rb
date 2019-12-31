require 'spec_helper'

RSpec.shared_examples_for 'a JSON account' do
  describe 'account as JSON' do
    it 'should include an id' do
      expect(subject['id']).to be_a(Integer)
    end
    it 'should include a name' do
      expect(subject['name']).to eq account_name
    end
    it 'should include include the balance' do
      expect(subject['balance']).to be_a(Integer)
    end
    it 'should return cashflow' do
      expect(subject['cash_flow']).to be_a_boolean
    end
  end
end


RSpec.describe 'AccountsApi', type: :request do
  describe 'GET routes' do
    let(:checking) { FactoryBot.create(:checking_account, name: '1st Tenn') }
    let(:savings) { FactoryBot.create(:savings_account, name: 'Savings') }
    let!(:accounts) { [checking, savings].map(&:to_hash) }

    subject { get endpoint }
    let(:body) { subject.body }

    describe '/accounts (index)' do
      let(:endpoint) { '/accounts' }
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
          { errors: ["Could not find a(n) account with id: #{checking.id}404"] }.to_json
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

  describe 'POST /accounts' do
    let(:endpoint) { '/accounts' }

    context 'valid params' do
      let(:account_name) { '1st Tenn' }
      let(:body) { { name: account_name, priority: rand(100) } }
      let(:response) { post endpoint, body }
      it 'should create a new resource' do
        expect { response }.to change { Account.count }.by 1
      end

      subject { JSON.parse(response.body) }

      include_examples 'a JSON account'
    end

    context 'invalid params' do
      let(:response) { post endpoint, post_body }
      let(:status) { response.status }
      let(:response_body) { JSON.parse(response.body) }

      context 'invalid params - lacking "priority"' do
        let(:post_body) { { name: 'Last National Credit Union' } }

        it { expect(status).to be 422 }

        it 'should have an error message' do
          expect(response_body['errors']).to eq('priority' => ["can't be blank"])
        end
      end

      context 'invalid params - lacking "name"' do
        let(:post_body) { { priority: rand(100) } }

        it { expect(status).to be 422 }

        it 'should have an error message' do
          expect(response_body['errors']).to eq('name' => ["can't be blank"])
        end
      end

      context 'duplicate account name' do
        let(:account) { FactoryBot.create(:account) }
        let(:priority) { Account.maximum(:priority).next }
        let(:post_body) { { name: account.name, priority: priority } }

        it { expect(status).to be 422 }
        it 'should have an error message' do
          expect(response_body['errors']).to eq('name' => ['has already been taken'])
        end
      end

      context 'duplicate priority' do
        let(:account) { FactoryBot.create(:account) }
        let(:priority) { account.priority }
        let(:post_body) { { name: '23rd St. Bank', priority: priority } }

        it { expect(status).to be 422 }
        it 'should have an error message' do
          expect(response_body['errors']).to eq('priority' => ['has already been taken'])
        end
      end
    end
  end

  describe 'PUT /accounts/:id' do
    let!(:account) { FactoryBot.create(:account, cash_flow: true) }
    let(:account_name) { account.name }
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

  describe 'DELETE /accounts/:id' do
    let!(:account) { FactoryBot.create(:account) }
    let(:endpoint) { "/accounts/#{account.id}" }
    let(:response) { delete endpoint }

    context 'no transactions' do
      it 'returns a 204' do
        expect(response.status).to be 204
      end

      it 'hard deletes the record' do
        expect { response }.to change { Account.count }.by(-1)
      end
    end

    context 'transactions exist' do
      before { FactoryBot.create(:transaction_entry, account: account) }

      it 'returns a 204' do
        expect(response.status).to be 204
      end

      it 'updates deleted_at on the record' do
        expect { response }.to(change { account.reload.archived_at })
      end

      it 'soft deletes the record' do
        expect { response }.to_not change { Account.count }
      end
    end
  end
end
