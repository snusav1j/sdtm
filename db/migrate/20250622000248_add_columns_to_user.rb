class AddColumnsToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :role, :string
    add_column :users, :firstname, :string
    add_column :users, :lastname, :string
    add_column :users, :balance, :float, default: 0.0, null: false
  end
end