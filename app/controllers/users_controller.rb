class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[ show edit update destroy update_user_image user_image_modal popup_balance_modal ]

  def index
    @users = User.all
    @user = User.new
  end

  def show

  end

  def popup_balance
    user_id = params.dig(:user, :id)
    balance = params.dig(:user, :balance)

    @user = User.find_by_id(user_id)
    if @user
      @balance_updated = @user.popup_user_balane(balance)

    else
      flash[:danger] = "Пользователь не найден"
    end
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user, notice: 'Пользователь успешно создан.'
    else
      @users = User.all 
      render :index
    end
  end
  
  def update

    filtered_params = user_params

    if filtered_params[:password].blank?
      filtered_params = filtered_params.except(:password, :password_confirmation)
    end

    if @user.update(filtered_params)
      flash[:success] = "Данные обновлены"
    else
      flash[:danger] = "Произошла ошибка"
    end

    redirect_to edit_user_path(@user)
  end

  def edit

  end

  def destroy
    if @user.destroy
      flash[:success] = "Пользователь удалён"
    else
      flash[:danger] = "Ошибка при удалении пользователя"
    end
    redirect_to users_path
  end

  def update_user_image
    file = params[:user_image_file]
    if file.present? && @user.present?
      @updated = @user.make_user_image_file(file)
    else
      @updated = false
    end

    respond_to do |format|
      format.html { redirect_to user_path(@user) } # для обычных запросов
      format.js   # отрендерит update_user_image.js.erb
    end
  end

  def user_image_modal

  end

  def popup_balance_modal

  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    # Обрати внимание: :password_confirmation, а не :confirm_password
    params.require(:user).permit(:firstname, :lastname, :role, :email, :password, :password_confirmation, :balance)
  end
end
