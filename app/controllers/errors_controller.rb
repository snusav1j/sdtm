class ErrorsController < ApplicationController
  def not_found
    redirect_to root_path, alert: "Страница не найдена"
  end

  def internal_server_error
    redirect_to root_path, alert: "Внутренняя ошибка сервера"
  end

  def bad_request
    redirect_to root_path, alert: "Некорректный запрос"
  end
end
