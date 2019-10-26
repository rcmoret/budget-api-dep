require 'spec_helper'

RSpec.describe 'transaction endpoints', type: :request do

  # transactions index
  describe 'GET /accounts/:id/transactions' do
    let(:checking) { FactoryBot.create(:account) }
    let(:query) { {} }
    let(:response) { get endpoint }
    let(:parsed_response) { JSON.parse(response.body) }

    context 'using an account id that does not exist' do
      let(:endpoint) do
        "/accounts/40#{checking.id}4/transactions?#{query.to_query}"
      end

      it 'returns a 404' do
        expect(response.status).to be 404
      end

      it 'responds with an error message' do
        expect(JSON.parse(response.body)['errors'])
          .to include "Could not find a(n) account with id: 40#{checking.id}4"
      end
    end

    describe 'the metadata' do
      subject { parsed_response }

      let(:endpoint) { "/accounts/#{checking.id}/transactions/metadata?#{query.to_query}" }

      describe 'date range' do
        let(:beginning_date) { Date.new(year, month, 1) }
        let(:ending_date) { Date.new(year, month, -1) }

        subject { super()['date_range'] }

        let(:month) { (1..12).to_a.sample }
        let(:year) { (2000..2099).to_a.sample }

        context 'specified month/year' do
          let(:query) { { month: month, year: year } }
          it { should eq [beginning_date, ending_date].map(&:to_s) }
        end
      end
    end

    describe 'the transaction collection' do
      subject { parsed_response }

      let(:endpoint) { "/accounts/#{checking.id}/transactions?#{query.to_query}" }

      before do
        Timecop.freeze(Time.current.beginning_of_minute)
        transaction
      end


      let(:transaction) { FactoryBot.create(:transaction, account: checking).view }
      let(:transaction_hash) { JSON.parse(transaction.to_json) }
      it { should be_a Array }
      it { expect(subject[0]).to eq transaction_hash }
    end
  end

  describe 'GET /accounts/:account_id/transactions/:id' do
    let(:transaction) { FactoryBot.create(:transaction) }
    let(:account) { transaction.account }
    let(:entry) { Transaction::Record.find(transaction.id) }
    let(:endpoint) { "/accounts/#{account.id}/transactions/#{transaction.id}" }

    subject { get endpoint }

    it 'returns a 200' do
      expect(subject.status).to be 200
    end

    it 'returns a transaction' do
      simple_resp = JSON.parse(subject.body, symbolize_names: true).except(:updated_at, :created_at)
      expect(simple_resp)
        .to eq entry.to_hash.except(:created_at, :updated_at)
    end
  end

  # transactions POST
  describe 'transactions POST' do
    let(:checking) { FactoryBot.create(:account) }
    let(:endpoint) { "/accounts/#{checking.id}/transactions" }
    let(:response) { post endpoint, transaction_attributes }
    let(:status) { response.status }

    subject { JSON.parse(response.body) }

    context 'simple transaction' do
      let(:item) { FactoryBot.create(:weekly_expense) }
      let(:transaction_attributes) do
        { description: 'Kroger', amount: -60.0, clearance_date: '2015-01-04', budget_item_id: item.id }
      end

      it 'returns a 201' do
        expect(status).to be 201
      end

      it 'creates a new transaction' do
        expect { subject }.to change { Primary::Transaction.count }.by(1)
      end

      let(:expected_hash) do
        transaction_attributes.stringify_keys.merge(
          'account_id' => checking.id,
          'account_name' => checking.name,
          'budget_item_id' => item.id,
          'budget_category' => item.name,
        )
      end
      it 'returns the JSON version of the transaction' do
        expect(subject).to include(expected_hash)
      end

      context 'submitting an invalid transaction' do
        let(:endpoint) { "/accounts/#{checking.id}/transactions" }
        let(:response) { post endpoint, transaction_attributes }
        let(:status) { response.status }
        let(:transaction_attributes) do
          { description: 'Kroger', clearance_date: '2015-01-04', budget_item_id: item.id }
        end

        it 'returns a 422' do
          expect(response.status).to be 422
        end

        it 'returns an error message' do
          expect(JSON.parse(response.body)['errors']).to eq('amount' => ["can't be blank"])
        end
      end

      context 'transaction with subs' do
        let(:grocery) { FactoryBot.create(:weekly_expense) }
        let(:clothes) { FactoryBot.create(:weekly_expense) }
        let(:subtransactions_attributes) do
          [ { description: 'Clothes', amount: -20.0, budget_item_id: clothes.id },
            { description: 'Food', amount: -35.0, budget_item_id: grocery.id } ]
        end
        let(:clearance_date) { '2019-12-31' }
        let(:base_attrs) do
          { description: 'Kroger', amount: -60.0, clearance_date: clearance_date }
        end
        let(:transaction_attributes) do
          base_attrs.merge(subtransactions_attributes: subtransactions_attributes)
        end
        let(:expected_amount) do
          subtransactions_attributes.map { |attrs| attrs[:amount] }.reduce(:+)
        end

        it 'returns a 201' do
          expect(status).to be 201
        end

        it 'creates a new transaction' do
          expect { subject }.to change { Primary::Transaction.count }.by(1)
        end

        it 'creates 2 new subtransactions' do
          expect { subject }.to change { Sub::Transaction.count }.by(2)
        end

        let(:expected_hash) do
          base_attrs.stringify_keys.merge(
            'account_id' => checking.id,
            'amount' => expected_amount,
            'account_name' => checking.name,
            'budget_category' => nil,
            'budget_item_id' => nil,
          )
        end

        it 'returns the JSON version of the transaction' do
          expect(subject).to include(expected_hash)
        end

        it 'returns the JSON version of the subtransactions' do
          expect(subject['subtransactions'][0]).to include(
            'budget_category' => clothes.name,
            'budget_item_id' => clothes.id,
            'amount' => subtransactions_attributes[0][:amount],
            'description' => 'Clothes',
          )
        end

        it 'returns the JSON version of the subtransactions' do
          expect(subject['subtransactions'][1]).to include(
            'budget_category' => grocery.name,
            'budget_item_id' => grocery.id,
            'amount' => subtransactions_attributes[1][:amount],
            'description' => 'Food',
          )
        end
      end
    end
  end

  # transactions PUT
  describe '/accounts/:account_id/transactions/:id' do
    context 'basic transaction' do
      let(:transaction) { FactoryBot.create(:transaction) }
      let(:account) { transaction.account }
      let(:clearance_date) { '2019-01-01' }
      let(:endpoint) { "/accounts/#{account.id}/transactions/#{transaction.id}" }
      let(:body) { { clearance_date: clearance_date } }
      let(:response) { put endpoint, body }

      it { expect(response.status).to be 200 }
      it 'changes the record' do
        expect { response }.to change { transaction.reload.clearance_date }
      end
    end

    context 'with subtransaction' do
      let(:subtransaction) { FactoryBot.create(:subtransaction) }
      let!(:transaction) { subtransaction.primary_transaction }
      let(:account) { transaction.account }
      let(:endpoint) { "/accounts/#{account.id}/transactions/#{transaction.id}" }
      let(:response) { put endpoint, body }

      describe 'updating a subtransaction' do
        let(:body) { { subtransactions_attributes: [{ id: subtransaction.id, amount: 10000 }] } }
        it { expect(response.status).to be 200 }
        it 'changes the subtransaction amount' do
          expect { response }.to change { subtransaction.reload.amount }
        end
      end

      describe 'adding a subtransaction' do
        let(:body) { { subtransactions_attributes: [{ amount: -1000 }] } }
        it { expect(response.status).to be 200 }
        it 'changes the count' do
          expect { response }.to change { transaction.reload.subtransactions.count }.by(1)
        end
      end

      describe 'deleting a subtransaction' do
        let(:body) { { subtransactions_attributes: [{ id: subtransaction.id, _destroy: true }] } }
        it { expect(response.status).to be 200 }
        it 'changes the count' do
          expect { response }.to change { transaction.reload.subtransactions.count }.by(-1)
        end
      end
    end
  end

  # transactions DELETE
  describe 'DELETE /account/:account_id/transactions/:id' do
    let!(:transaction) { FactoryBot.create(:transaction) }
    let(:account) { transaction.account }
    let(:endpoint) { "/accounts/#{account.id}/transactions/#{transaction.id}" }
    let(:response) { delete endpoint }

    context 'no subtransactions' do
      it { expect(response.status).to be 204 }
      it 'deletes the transaction' do
        expect { response }.to change { Primary::Transaction.count }.by(-1)
      end
    end

    context 'subtransactions exist' do
      let!(:subtransaction) { FactoryBot.create(:subtransaction) }
      let(:transaction) { subtransaction.primary_transaction }
      it { expect(response.status).to be 204 }
      it 'deletes the transaction' do
        expect { response }.to change { Primary::Transaction.count }.by(-1)
      end
      it 'deletes the subtransactions' do
        expect { response }.to change { Sub::Transaction.count }.by(-1)
      end
    end
  end
end
