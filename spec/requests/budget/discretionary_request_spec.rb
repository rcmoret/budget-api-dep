require 'spec_helper'

RSpec.describe 'discretionary endpoint' do
  let(:transaction) { FactoryBot.create(:transaction, :discretionary) }
  let(:endpoint) { '/budget/discretionary/transactions' }
  let(:response) { get endpoint }
  before do
    transaction
    FactoryBot.create(:transaction)
  end

  subject { response.body }

  it 'returns a name' do
    record = Transaction::Record.find(transaction.id)
    expect(subject).to eq [record.to_hash].to_json
  end
end
