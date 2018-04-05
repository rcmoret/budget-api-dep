module SharedExamples
  module TransactionExamples
    shared_examples_for 'JSON transaction (base)' do
      it 'should have an id' do
        expect(subject['id']).to be_a Fixnum
      end
      it 'should have a description' do
        description = subject.fetch('description')
        expect(description).to eq transaction_attributes[:description]
      end
      it 'should have a clearance_date' do
        expect(subject['clearance_date']).to eq transaction_attributes[:clearance_date]
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
        expect(subject['budget_exclusion']).to be_a_boolean
      end
    end
    shared_examples_for 'JSON transaction' do
      include_examples 'JSON transaction (base)'
      it 'should have an amount' do
        amount = subject['amount'].to_f
        expect(amount).to eq transaction_attributes[:amount]
      end
    end
    shared_examples_for 'JSON transaction with subtransactions' do
      include_examples 'JSON transaction (base)'
      let(:amount) { subject['amount'].to_f }
      let(:expected_amount) do
        subtransactions_attributes.values.inject(0) do |sum, attr|
          sum += attr[:amount]
        end
      end
      it 'should have an amount' do
        expect(amount).to eq expected_amount
      end
      it 'should return the subtransactions' do
        subtransaction = subject['subtransactions_attributes'].values.first
        expect(subtransaction['description']).to eq 'Food'
        expect(subtransaction['amount']).to eq -35.0
      end
    end
  end
end
