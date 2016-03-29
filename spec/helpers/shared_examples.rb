module Helpers
  module SharedExamples
    shared_examples_for 'a JSON account' do
      describe 'account as JSON' do
        it 'should include an id' do
          expect(subject['id']).to be_a(Fixnum)
        end
        it 'should include a name' do
          expect(subject['name']).to eq checking.name
        end
        it 'should include include the balance' do
          expect(subject['balance']).to be_a(Float)
        end
        it 'should return cashflow' do
          expect(subject['cash_flow']).to be_a_boolean
        end
        it 'should return HSA' do
          expect(subject['health_savings_account']).to be_a_boolean
        end
      end
    end
    shared_examples_for 'account/transactions metadata JSON' do
      describe 'metadata' do
        it 'should have the date range used for the query' do
          range = subject['date_range']
          expect(range.first).to respond_to :to_date
          expect(range.last).to respond_to :to_date
          expect(range.first.to_date).to be < range.last.to_date
        end
        it 'should include the prior balance' do
          expect(subject['prior_balance']).to be_a Float
        end
        it 'should include extra parameters' do
          expect(subject['query_options']).to be_a Hash
        end
      end
    end
    shared_examples_for 'JSON transaction' do
      it 'should have an id' do
        expect(subject['id']).to be_a Fixnum
      end
      it 'should have an amount' do
        amount = subject['amount'].to_f
        expect(amount).to eq post_body[:amount]
      end
      it 'should have a description' do
        description = subject.fetch('description')
        expect(description).to eq post_body[:description]
      end
      it 'should have a clearance_date' do
        expect(subject['clearance_date']).to eq post_body[:clearance_date]
      end
      it 'should have the account info'do
        expect(subject['account_id']).to eq checking.id
        expect(subject['account_name']).to eq checking.name
      end
      it 'should have the following things (usually nil)' do
        expect(subject.fetch('check_number')).to be_nil
        expect(subject.fetch('notes')).to be_nil
        expect(subject.fetch('receipt')).to be_nil
      end
      it 'should have tax deduction and qme flags' do
        expect(subject['tax_deduction']).to be_a_boolean
        expect(subject['qualified_medical_expense']).to be_a_boolean
      end
      it 'should have an array of subtransactions' do
        expect(subject['subtransactions']).to be_a Array
        expect(subject['subtransactions']).to be_empty
      end
    end
  end
end
