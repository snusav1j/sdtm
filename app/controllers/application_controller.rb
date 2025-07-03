class ApplicationController < ActionController::Base
  include  ApplicationHelper
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern
  # rescue_from ActionController::RoutingError, with: :handle_routing_error
  
  before_action :create_super_user
  before_action :set_global_vars

  def create_super_user
    def create_super_user
      User.create!(
        email: 'danek@gmail.com',
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
    redirect_to root_path, alert: "Страница не найдена"
  end
  

  private

  def handle_routing_error
    flash[:danger] = "Имя ошибки"
    redirect_to root_path
  end
end
