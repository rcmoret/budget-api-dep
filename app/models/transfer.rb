# frozen_string_literal: true

class Transfer < ActiveRecord::Base
  belongs_to :from_transaction, class_name: 'Transaction::Entry'
  belongs_to :to_transaction, class_name: 'Transaction::Entry'

  after_create :update_transactions!

  scope :recent_first, -> { order(created_at: :desc) }

  def destroy
    update_transactions!(destroy: true)
    super
    transactions.each(&:destroy)
  end

  def to_hash
    attributes.symbolize_keys.merge(
      to_transaction: to_transaction.attributes,
      from_transaction: from_transaction.attributes
    )
  end

  private

  def update_transactions!(destroy: false)
    transfer_id = destroy ? nil : id
    ActiveRecord::Base.transaction do
      transactions.each { |txn| txn.update(transfer_id: transfer_id) }
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
      transfer
        .build_from_transaction(
          description: from_description,
          account: from_account,
          details_attributes: [
            { amount: -amount },
          ]
        )
    end

    def from_description
      "Transfer to #{to_account}"
    end

    def to_transaction
      transfer
        .build_to_transaction(
          description: to_description,
          account: to_account,
          details_attributes: [
            { amount: amount },
          ]
        )
    end

    def to_description
      "Transfer from #{from_account}"
    end
  end
end
