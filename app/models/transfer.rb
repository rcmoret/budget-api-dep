class Transfer < ActiveRecord::Base
  belongs_to :from_transaction, class_name: 'Primary::Transaction'
  belongs_to :to_transaction, class_name: 'Primary::Transaction'

  after_create :update_transactions!

  def destroy
    update_transactions!(destroy: true)
    super
    transactions.each(&:destroy)
  end

  def to_hash
    attributes.symbolize_keys.merge(
      to_transaction: to_transaction.to_hash, from_transaction: from_transaction.to_hash
    )
  end

  private

  def update_transactions!(destroy: false)
    transfer_id = destroy ? nil : id
    ActiveRecord::Base.transaction do
      transactions.each { |transaction| transaction.update(transfer_id: transfer_id) }
    end
  end

  def transactions
    [to_transaction, from_transaction]
  end

  class Generator
    def self.create(to_account:, from_account:, amount:)
      new(to_account: to_account, from_account: from_account, amount: amount).create
    end

    attr_reader :to_account, :from_account, :amount

    def initialize(to_account:, from_account:, amount:)
      raise DuplicateAccountError, 'Must provide distinct accounts' if to_account == from_account

      @to_account = to_account
      @from_account = from_account
      @amount = amount.to_i.abs
    end

    def create
      ActiveRecord::Base.transaction do
        [from_transaction, to_transaction, transfer].each(&:save)
      end
      transfer
    end

    DuplicateAccountError = Class.new(StandardError)

    private

    def transfer
      @transfer ||= Transfer.new
    end

    def from_transaction
      transfer.build_from_transaction(description: from_description, account: from_account, amount: -amount)
    end

    def from_description
      "Transfer from #{from_account}"
    end

    def to_transaction
      transfer.build_to_transaction(description: to_description, account: to_account, amount: amount)
    end

    def to_description
      "Transfer to #{to_account}"
    end
  end
end
