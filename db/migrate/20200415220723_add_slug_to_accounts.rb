class AddSlugToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :slug, :string, limit: 30
    # add_index :account, :slug, unique: true
  end
end
