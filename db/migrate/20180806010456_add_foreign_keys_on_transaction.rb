class AddForeignKeysOnTransaction < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :transactions, :monthly_amounts
  end
end
