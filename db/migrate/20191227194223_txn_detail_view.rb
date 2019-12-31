class TxnDetailView < ActiveRecord::Migration[5.1]
  UP_MIGRATION = <<-SQL
    CREATE view transaction_detail_view AS
      SELECT
             d.*, -- details' details
             e.id AS "entry_id", -- entry details --
             e.account_id,
             e.clearance_date,
             e.description,
             e.budget_exclusion,
             e.notes,
             e.receipt,
             e.transfer_id,
             e.created_at AS "entry_created_at",
             e.updated_at AS "entry_updated_at", -- entry details ^ --
             a.name AS "account_name", -- account details --
             c.name AS "category_name", -- budget category details --
             ic.class_name AS "icon_class_name" -- icon details --
      FROM transaction_entries e
      JOIN transaction_details d ON d.transaction_entry_id = e.id
      JOIN accounts a on a.id = e.account_id
      LEFT OUTER JOIN budget_items item ON item.id = d.budget_item_id
      LEFT OUTER JOIN budget_categories c ON c.id = item.budget_category_id
      LEFT OUTER JOIN icons ic ON ic.id = c.icon_id
  SQL

  def up
    execute(UP_MIGRATION)
  end

  def down
    execute('DROP VIEW if exists transaction_detail_view')
  end
end
