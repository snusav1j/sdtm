class DiceGamesController < ApplicationController
  before_action :authenticate_user!

  def index
    @dice_game = DiceGame.new()
    @history = DiceGame.get_history(current_user)
  end
  
  def clear_game_history
    @cleared = DiceGame.where(user_id: current_user.id).delete_all 
    if @cleared
      @history = DiceGame.get_history(current_user)
    end
  end

  def update_dice_game_settings
    @updated = DiceGameSetting.create_settings(current_user, params)
  end

  def dice_game_settings_modal

  end

  def create
    @bet_amount = dice_params[:bet_amount].to_f
    @chance = dice_params[:chance].to_f

    if @bet_amount > 0
      @game_played = DiceGame.play!(@chance, current_user, @bet_amount)
      @history = DiceGame.get_history(current_user)
    end
  end

  private

  def dice_params
    params.require(:dice_game).permit(:chance, :bet_amount)
  end


end
