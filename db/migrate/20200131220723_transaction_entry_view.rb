class TransactionEntryView < ActiveRecord::Migration[5.1]
  PG_SQL_UP = <<-SQL
      CREATE VIEW transaction_view AS
        SELECT t.*,
               a.name AS "account_name",
               TO_JSON(ARRAY(
                 SELECT JSON_BUILD_OBJECT(
                   'id', detail.id,
                   'budget_category', c.name,
                   'budget_item_id', detail.budget_item_id,
                   'amount', detail.amount,
                   'icon_class_name', ic.class_name
                 )
                 FROM transaction_details detail
                 LEFT OUTER JOIN budget_items i ON i.id = detail.budget_item_id
                 LEFT JOIN budget_categories c ON c.id = i.budget_category_id
                 LEFT JOIN icons ic ON ic.id = c.icon_id
                 WHERE detail.transaction_entry_id = t.id
               )) AS "details"
        FROM transaction_entries t
        LEFT JOIN accounts a ON a.id = t.account_id
  SQL

  PG_SQL_DOWN = <<-SQL
    CREATE VIEW transaction_view AS
      SELECT t.id,
             t.description AS "description",
             b.name AS "budget_category",
             ic.class_name AS "icon_class_name",
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
             (SELECT
               JSON_GROUP_ARRAY(
                 JSON_OBJECT(
                   'id', sub.id,
                   'amount', sub.amount,
                   'description', sub.description,
                   'budget_category', c.name,
                   'budget_item_id', sub.budget_item_id,
                   'primary_transaction_id', sub.primary_transaction_id,
                   'icon_class_name', ic1.class_name
                 )
               )
               FROM transactions sub
               LEFT OUTER JOIN budget_items i1 ON i1.id = sub.budget_item_id
               LEFT JOIN budget_categories c ON c.id = i1.budget_category_id
               LEFT JOIN icons ic1 ON ic1.id = c.icon_id
               WHERE sub.primary_transaction_id = t.id
             ) AS "subtransactions",
             t.updated_at AS "updated_at"
      FROM transactions t
      LEFT OUTER JOIN budget_items ma ON ma.id = t.budget_item_id
      LEFT JOIN budget_categories b on b.id = ma.budget_category_id
      LEFT JOIN accounts a ON a.id = t.account_id
      LEFT JOIN icons ic ON ic.id = b.icon_id
      WHERE t.primary_transaction_id IS NULL
  SQL

  LITE_SQL_UP = <<-SQL
      CREATE VIEW transaction_view AS
        SELECT t.*,
               a.name AS "account_name",
               (SELECT
                 JSON_GROUP_ARRAY(
                   JSON_OBJECT(
                     'id', detail.id,
                     'amount', detail.amount,
                     'budget_category', c.name,
                     'budget_item_id', detail.budget_item_id,
                     'icon_class_name', ic.class_name
                   )
                 )
                 FROM transaction_details detail
                 LEFT OUTER JOIN budget_items item ON item.id = detail.budget_item_id
                 LEFT JOIN budget_categories c ON c.id = item.budget_category_id
                 LEFT JOIN icons ic ON ic.id = c.icon_id
                 WHERE detail.transaction_entry_id = t.id
               ) AS "details"
        FROM transaction_entries t
        LEFT JOIN accounts a ON a.id = t.account_id
  SQL

  def up
    execute('DROP VIEW if exists transaction_view')
    adapter = database_config.fetch(ENV['RACK_ENV'], {}).fetch('adapter', '')
    case adapter
    when 'postgresql'
      execute(PG_SQL_UP)
    when 'sqlite3'
      execute(LITE_SQL_UP)
    else
      raise AdapterError,
            "No SQL defined for #{adapter} to create transaction views"
    end
  end

  def down
    execute('DROP VIEW if exists transaction_view')
  end

  AdapterError = Class.new(StandardError)

  private

  def database_config
    YAML.load(File.read('./config/database.yml'))
  end
end
