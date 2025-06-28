class DiceGameSetting < ApplicationRecord
  belongs_to :user

  def self.create_settings user, setting_params
    auto_play_bet_amount = setting_params[:auto_play_bet_amount]

    user_dice_game_settings = self.find_by(user_id: user.id)
    if user_dice_game_settings
      user_dice_game_settings.update(auto_play_bet_amount: auto_play_bet_amount)
    else
      user_dice_game_settings = self.create(user_id: user.id)
      user_dice_game_settings.update(auto_play_bet_amount: auto_play_bet_amount)
    end
  end
end