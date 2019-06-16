class CreateMaturityIntervalsView < ActiveRecord::Migration[5.1]
  VIEW_NAME = 'maturity_intervals_view'.freeze

  def up
    execute "DROP view if exists #{VIEW_NAME}"
    execute <<-SQL
      CREATE VIEW #{VIEW_NAME} AS
        SELECT mi.id, mi.budget_category_id, mi.budget_interval_id, i.month, i.year
        FROM budget_category_maturity_intervals mi
        JOIN budget_intervals i ON i.id = mi.budget_interval_id
    SQL
  end

  def down
    execute "DROP view if exists #{VIEW_NAME}"
  end
end
