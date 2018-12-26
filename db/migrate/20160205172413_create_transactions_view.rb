class CreateTransactionsView < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      CREATE VIEW transaction_view AS
        SELECT t.id, t.description AS "description",
               b.name AS "budget_category",
               t.budget_item_id AS "budget_item_id",
               t.clearance_date AS "clearance_date",
               COALESCE((SELECT sum(amount) FROM transactions WHERE primary_transaction_id = t.id), t.amount)
                 AS amount,
               a.name AS "account_name",
               a.id AS "account_id",
               t.check_number,
               t.receipt,
               t.notes,
               t.budget_exclusion,
               TO_JSON(ARRAY(
                 SELECT JSON_BUILD_OBJECT(
                   'id', sub.id,
                   'budget_category', c.name,
                   'budget_item_id', sub.budget_item_id,
                   'description', sub.description,
                   'amount', sub.amount
                 )
                 FROM transactions sub
                 LEFT OUTER JOIN budget_items i1 ON i1.id = sub.budget_item_id
                 LEFT JOIN budget_categories c ON c.id = i1.budget_category_id
                 WHERE sub.primary_transaction_id = t.id
               )) AS "subtransactions",
               t.updated_at AS "updated_at"
        FROM transactions t
        LEFT OUTER JOIN budget_items ma ON ma.id = t.budget_item_id
        LEFT JOIN budget_categories b on b.id = ma.budget_category_id
        LEFT JOIN accounts a ON a.id = t.account_id
        WHERE t.primary_transaction_id IS NULL
    SQL
  end

  def down
    execute('DROP VIEW if exists transaction_view')
  end
end
