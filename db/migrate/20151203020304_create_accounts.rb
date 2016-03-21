class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string  :name
      t.boolean :cash_flow,              default: true
      t.boolean :health_savings_account, default: false

      t.timestamps
    end
  end
end
