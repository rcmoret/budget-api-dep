class UpdateBudgetItemView < ActiveRecord::Migration[5.1]
  def up
    execute('DROP VIEW if exists budget_item_views')
    execute <<-SQL
      CREATE VIEW budget_item_views AS
      SELECT i.id, i.amount, i.budget_category_id, i.budget_interval_id,
          c.name AS name,
          c.expense AS expense,
          c.monthly AS monthly,
          c.accrual AS accrual,
          bi.month AS month,
          bi.year AS year,
          ic.class_name AS icon_class_name,
          (SELECT COUNT(t.id) FROM transactions t WHERE i.id = t.budget_item_id) AS transaction_count,
          (SELECT COALESCE(SUM(t.amount), 0) FROM transactions t WHERE i.id = t.budget_item_id) AS spent
        FROM budget_items i
        JOIN budget_categories c ON c.id = i.budget_category_id
        JOIN budget_intervals bi ON bi.id = i.budget_interval_id
        LEFT JOIN icons ic ON ic.id = c.icon_id
    SQL
  end

  def down
    execute('DROP VIEW if exists budget_item_views')
    execute <<-SQL
      CREATE VIEW budget_item_views AS
      SELECT i.id, i.amount, i.budget_category_id, i.budget_interval_id,
          c.name AS name,
          c.expense AS expense,
          c.monthly AS monthly,
          bi.month AS month,
          bi.year AS year,
          ic.class_name AS icon_class_name,
          (SELECT COUNT(t.id) FROM transactions t WHERE i.id = t.budget_item_id) AS transaction_count,
          (SELECT COALESCE(SUM(t.amount), 0) FROM transactions t WHERE i.id = t.budget_item_id) AS spent
        FROM budget_items i
        JOIN budget_categories c ON c.id = i.budget_category_id
        JOIN budget_intervals bi ON bi.id = i.budget_interval_id
        LEFT JOIN icons ic ON ic.id = c.icon_id
    SQL
  end
end