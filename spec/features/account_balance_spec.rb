require 'spec_helper'

RSpec.describe 'account.balance' do
  let(:primary_account) { FactoryBot.create(:account) }
  context 'account without transactions' do
    it 'should return 0' do
      expect(primary_account.transactions.count).to be 0
      expect(primary_account.balance).to eq 0
    end
  end
  context 'account with primary transactions' do
  end
  context 'accout with primary and sub-transactions' do
  end
  context 'multiple accounts' do
  end
end
