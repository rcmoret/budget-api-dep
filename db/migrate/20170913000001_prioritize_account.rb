class PrioritizeAccount < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :priority, :integer
  end
end
