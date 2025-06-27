class AddColumnUserImageNameAndCreateDice < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :image_name, :string

    create_table :dice_games do |t|
      t.references :user, null: false, foreign_key: true

      t.float :chance

      t.float :bet_amount
      t.float :win_amount
      t.float :lose_amount

      t.integer :roll_result
      t.string :game_result

      t.timestamps
    end
  end
end
