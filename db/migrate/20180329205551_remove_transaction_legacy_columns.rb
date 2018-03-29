class RemoveTransactionLegacyColumns < ActiveRecord::Migration[5.1]
  def up
    remove_column :transactions, :tax_deduction
    remove_column :transactions, :qualified_medical_expense
  end

  def down
    add_column :transactions, :tax_deduction, :boolean, default: false
    add_column :transactions, :qualified_medical_expense, :boolean, default: false
  end
end
