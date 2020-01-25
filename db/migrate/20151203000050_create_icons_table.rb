# frozen_string_literal: true

class CreateIconsTable < ActiveRecord::Migration[5.1]
  def change
    create_table :icons do |t|
      t.string :name, limit: 100, null: false
      t.string :class_name, limit: 100, null: false
      t.timestamps
    end
  end
end
