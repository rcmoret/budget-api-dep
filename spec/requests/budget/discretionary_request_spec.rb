# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'discretionary endpoint' do
  before { allow(Secret).to receive(:key).and_return('') }

  let(:transaction) { FactoryBot.create(:transaction_entry, :discretionary) }
  let(:endpoint) { '/budget/discretionary/transactions' }
  let(:response) { get endpoint }
  before do
    transaction
    FactoryBot.create(:transaction_entry)
  end

  subject { response.body }

  it 'returns a name' do
    view = Transaction::DetailView.find_by(
      transaction_entry_id: transaction.id
    )
    expect(subject).to eq [view.to_hash].to_json
  end
end
