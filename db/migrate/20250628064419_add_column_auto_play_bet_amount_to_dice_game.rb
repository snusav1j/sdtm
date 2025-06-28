class AddColumnAutoPlayBetAmountToDiceGame < ActiveRecord::Migration[8.0]
  def change
    create_table :dice_game_settings do |t|
      t.references :user, null: false, foreign_key: true
      t.float :auto_play_bet_amount
      t.timestamps
    end
  end
end
