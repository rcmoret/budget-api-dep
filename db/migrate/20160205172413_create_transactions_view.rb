class CreateTransactionsView < ActiveRecord::Migration
  SUM_QRY = %Q{COALESCE((SELECT sum(amount) FROM transactions WHERE primary_transaction_id = t.id), t.amount)}

  SUB_QRY = <<-SQL
    TO_JSON(ARRAY(
      SELECT JSON_BUILD_OBJECT(
        'id', sub.id,
        'budget_item', i.name,
        'monthly_amount_id', sub.monthly_amount_id,
        'description', sub.description, 'amount', sub.amount)
      FROM transactions sub
      LEFT OUTER JOIN monthly_amounts m1 ON m1.id = sub.monthly_amount_id
      LEFT JOIN budget_items i ON i.id = m1.budget_item_id
      WHERE sub.primary_transaction_id = t.id
    ))
  SQL

  def up
    execute <<-SQL
      CREATE VIEW transaction_view AS
        SELECT t.id, t.description AS "description",
               b.name AS "budget_item",
               t.monthly_amount_id AS "monthly_amount_id",
               t.clearance_date AS "clearance_date",
               #{SUM_QRY} AS amount,
               a.name AS "account_name",
               a.id AS "account_id",
               t.check_number,
               t.receipt,
               t.notes,
               t.tax_deduction,
               t.qualified_medical_expense,
               #{SUB_QRY}  AS subtransactions_attributes,
               t.updated_at AS "updated_at"
        FROM transactions t
        LEFT OUTER JOIN monthly_amounts ma ON ma.id = t.monthly_amount_id
        LEFT JOIN budget_items b on b.id = ma.budget_item_id
        LEFT JOIN accounts a ON a.id = t.account_id
        WHERE t.primary_transaction_id IS NULL
        ORDER BY t.clearance_date ASC, t.clearance_date IS NULL, t.updated_at ASC
    SQL
  end

  def down
    execute('DROP VIEW transaction_view')

  end
end
