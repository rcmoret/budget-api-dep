class CreateTransactionsView < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE VIEW transaction_view AS
        SELECT t.id, t.description AS "description", b.name, t.clearance_date AS "clearance_date", t.notes, t.receipt, t.check_number, t.account_id AS "account_id",
          COALESCE((SELECT sum(amount) FROM transactions WHERE primary_transaction_id = t.id), t.amount) AS amount,
          TO_JSON(ARRAY(
            SELECT JSON_BUILD_OBJECT('id', sub.id, 'name', i.name, 'description', sub.description, 'amount', sub.amount)
            FROM transactions sub
            LEFT OUTER JOIN monthly_amounts m1 ON m1.id = sub.monthly_amount_id
            LEFT JOIN budget_items i ON i.id = m1.budget_item_id
            WHERE sub.primary_transaction_id = t.id
          )) AS subtransactions
        FROM transactions t
        LEFT OUTER JOIN monthly_amounts ma ON ma.id = t.monthly_amount_id
        LEFT JOIN budget_items b on b.id = ma.budget_item_id
        WHERE t.primary_transaction_id IS NULL

    SQL
  end

  def down
    execute('DROP VIEW transaction_view')

  end
end
