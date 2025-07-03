module ApplicationHelper
  include TranslateHelper

  def pretty_date(date)
    date.strftime("%d %B %Y") if date.present?
  end

  def pretty_date_month_year(date)
    date.strftime("%B %Y") if date.present?
  end

  def pretty_number(number, delimiter = '')
    number_to_currency number, precision: 0, delimiter: delimiter, unit: ""
  end

  def pretty_decimal(number, separator = '.', delimiter = '')
    # Используем NumberHelper через ActionView::Helpers::NumberHelper
    ActionController::Base.helpers.number_to_currency(number, precision: 2, delimiter: delimiter, unit: "", separator: separator)
  end

  def pretty_date_time(date)
    date.strftime("%d %B %Y %H:%M") if date.present?
  end

  def small_date(date)
    date.strftime("%d.%m.%Y") if date.present?
  end

  def small_date_hyphen(date)
    date.strftime("%d-%m-%Y") if date.present?
  end

  def time_only(date)
    date.strftime("%H:%M") if date.present?
  end

  def smallest_date(date)
    date.strftime("%d.%m") if date.present?
  end

  def small_datetime(date)
    date.strftime("%d.%m.%Y %H:%M") if date.present?
  end

  def format_number(number, precision: 2, delimiter: ',', separator: '.')
    number_with_precision(
      number,
      precision: precision,
      delimiter: delimiter,
      separator: separator
    )
  end

  # user

  def logo_icon
    image_tag "/icons/vexodus_mini.png"
  end

  def g_icon icon_name
    content_tag(:span, icon_name, class: "material-symbols-outlined g-icon")
  end

  def user_image(user = nil)
    user ||= current_user
    image_tag user.user_image_url
  end
    
  def active_sidebar?(url_path)
    url_path.include?("/#{@cur_url}") || url_path == @cur_url
  end
end


