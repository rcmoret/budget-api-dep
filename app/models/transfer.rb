class Transfer < ActiveRecord::Base
  belongs_to :from_transaction, class_name: 'Primary::Transaction'
  belongs_to :to_transaction, class_name: 'Primary::Transaction'

  after_create :update_transactions!

  def destroy
    update_transactions!(destroy: true)
    super
    transactions.each(&:destroy)
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
end
