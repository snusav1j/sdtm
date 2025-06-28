class AddColumnAutoPlayBetAmountToDiceGame < ActiveRecord::Migration[8.0]
  def change
    add_column :dice_games, :auto_play_bet_amount, :float
  end
end
