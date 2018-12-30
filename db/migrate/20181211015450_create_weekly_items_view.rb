class CreateWeeklyItemsView < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      CREATE VIEW budget_weekly_items AS
        SELECT i.*,
          c.name AS name,
          c.expense AS expense,
          c.monthly AS monthly,
          ic.class_name AS icon_class_name,
          ic.name AS icon_name,
          (SELECT COALESCE(SUM(t.amount), 0) FROM transactions t WHERE i.id = t.budget_item_id) AS total
        FROM budget_items i
        JOIN budget_categories c ON c.id = i.budget_category_id
        LEFT JOIN icons ic ON ic.id = c.icon_id
        WHERE c.monthly = 'f'
    SQL
  end

  def down
    execute('DROP VIEW budget_weekly_items')
  end
end
