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
  end
end
