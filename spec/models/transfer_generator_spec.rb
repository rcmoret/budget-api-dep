require 'spec_helper'

RSpec.describe Transfer::Generator do
  subject { described_class.create(args) }

  describe 'happy path' do
    let(:to_account) { FactoryBot.create(:account) }
    let(:from_account) { FactoryBot.create(:account) }
    let(:amount) { (100..1000).to_a.sample }
    let(:args) do
      { to_account: to_account, from_account: from_account, amount: amount }
    end

    it 'creates 2 new transactions' do
      expect { subject }.to change { Transaction::Record.count }.by(+2)
    end

    it 'creates a new transer' do
      expect { subject }.to change { Transfer.count }.by(+1)
    end

    it 'returns the transfer' do
      expect(subject).to be_a Transfer
    end

    context 'accounts are the same' do
      let(:amount) { (100..1000).to_a.sample }
      let(:args) do
        { to_account: to_account, from_account: to_account, amount: amount }
      end

      it 'raises an error' do
        expect { subject }.to raise_error(Transfer::Generator::DuplicateAccountError)
      end
    end
  end
end
