class ApplicationController < ActionController::Base
  include  ApplicationHelper
  rescue_from ActionController::RoutingError, with: :route_not_found
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern
  # rescue_from ActionController::RoutingError, with: :handle_routing_error
  
  before_action :create_super_user
  before_action :set_global_vars

  # def mark_online
  #   OnlineTracker.mark_online(current_user) if current_user.present?
  # end

  def ensure_super_user
    User::SUPER_USERS_LIST.include? current_user.role
  end
  
  def check_super_user_access
    unless ensure_super_user
      flash[:danger] = "У вас нет прав для доступа к этой странице."
      redirect_to root_path
    end
  end
  
  def create_super_user
    user_present = User.find_by(email: "snusavij@gmail.com")
    if !user_present.present?
      User.create!(
        email: 'snusavij@gmail.com',
        password: '123456',
        password_confirmation: '123456',
        role: 'dev',
        firstname: 'sdtm',
        lastname: 'dev',
        balance: 1000
      )
    end
  end

  def set_global_vars
    @http_host = request.env['HTTP_HOST']
    @cur_url = request.env['REQUEST_URI']
		@ref_url = request.env['HTTP_REFERER']

    @http_address = "#{@http_host}/#{@cur_url}"
  end

  # telegram

  def send_tg_message_to_dev(msg)
    chat_id = "6393964092"
    token = "7680590872:AAGfpNQc5tJO8UKASClsx1rOzBDsvRk_9zc"
    Telegram::Bot::Client.run(token) do |bot|
      bot.api.send_message(chat_id: chat_id, text: msg)
    end
  end

  def send_tg_message(msg)
    token = "7680590872:AAGfpNQc5tJO8UKASClsx1rOzBDsvRk_9zc"
    chat_id = current_user.tg_chat_id

    if chat_id
      Telegram::Bot::Client.run(token) do |bot|
        bot.api.send_message(chat_id: chat_id, text: msg)
      end
    end
  end


  def route_not_found
    # flash[:danger] = "Страница не найдена"
    redirect_to root_path
  end

  private

end
