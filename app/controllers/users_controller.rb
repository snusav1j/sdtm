class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[ show edit update destroy ]

  def index
    @users = User.all
  end

  def show

  end

  def popup_balance
    user_id = params[:user][:id]
    balance = params[:user][:balance]

    @user = User.find_by_id(user_id)
    if @user
      @balance_updated = @user.popup_user_balane(balance)
    end
  end
  
  def update
    
  end

  def edit

  end

  def destroy

  end

  def update_user_image
    user = User.find(params[:user_id])
    file = params[:user_image_file]
    if file.present? && user.present?
      @updated = user.make_user_image_file(file)
    end
    respond_to do |format|
      format.html { redirect_to user_path(user) } # для обычных запросов
      format.js   # отрендерит update_user_image.js.erb
    end
  end

  def user_image_modal
    user_id = params[:user_id]
    @user = User.find_by_id(user_id)
  end

  def popup_balance_modal
    user_id = params[:user_id]
    @user = User.find_by_id(user_id)
  end

  private

  def users_params
    params.require(:user).permit()
  end

  def set_user
    @user = User.find(params.expect(:id))
  end


end