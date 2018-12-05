class TransferGenerator
  def self.create(to_account:, from_account:, amount:)
    new(to_account: to_account, from_account: from_account, amount: amount).create
  end

  attr_reader :to_account, :from_account, :amount

  def initialize(to_account:, from_account:, amount:)
    @to_account = to_account
    @from_account = from_account
    @amount = amount
  end

  def create
    ActiveRecord::Base.transaction do
      [from_transaction, to_transaction, transfer].each(&:save)
    end
  end

  private

  def transfer
    @transfer ||= Transfer.new
  end

  def from_transaction
    transfer.build_from_transaction(description: from_description, account: from_account, amount: -amount)
  end

  def from_description
    "Transfer to #{to_account.name}"
  end

  def to_transaction
    transfer.build_to_transaction(description: from_description, account: to_account, amount: amount)
  end

  def to_description
    "Transfer to #{from_account.name}"
  end
end
