class SoftDeleteAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :deleted_at, :timestamp
  end
end
