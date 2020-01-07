class AddNonNullForExclusion < ActiveRecord::Migration[5.1]
  def up
    change_column_null(:transaction_entries, :budget_exclusion, false)
    change_column_default(:transaction_entries, :budget_exclusion, false)
  end

  def down
    change_column_null(:transaction_entries, :budget_exclusion, true)
    change_column_default(:transaction_entries, :budget_exclusion, nil)
  end
end
