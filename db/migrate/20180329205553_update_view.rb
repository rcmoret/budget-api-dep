require_relative './20160205172413_create_transactions_view'

class UpdateView < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      CREATE VIEW transaction_view AS
        SELECT t.id, t.description AS "description",
               b.name AS "budget_item",
               t.monthly_amount_id AS "monthly_amount_id",
               t.clearance_date AS "clearance_date",
               #{CreateTransactionsView::SUM_QRY} AS amount,
               a.name AS "account_name",
               a.id AS "account_id",
               t.check_number,
               t.receipt,
               t.notes,
               t.budget_exclusion,
               #{CreateTransactionsView::SUB_QRY}  AS subtransactions_attributes,
               t.updated_at AS "updated_at"
        FROM transactions t
        LEFT OUTER JOIN monthly_amounts ma ON ma.id = t.monthly_amount_id
        LEFT JOIN budget_items b on b.id = ma.budget_item_id
        LEFT JOIN accounts a ON a.id = t.account_id
        WHERE t.primary_transaction_id IS NULL
        ORDER BY t.clearance_date IS NOT NULL AND t.clearance_date > NOW(),
                 t.clearance_date IS NULL,
                 t.clearance_date ASC,
                 t.updated_at ASC
    SQL
  end

  def down
    execute('DROP VIEW if exists transaction_view')
  end
end
