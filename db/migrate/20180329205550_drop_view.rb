require_relative './20160205172413_create_transactions_view'

class DropView < ActiveRecord::Migration[5.1]
  def up
    execute('DROP VIEW if exists transaction_view')
  end

  def down
    execute(CreateTransactionsView::CREATE_SQL)
  end
end
