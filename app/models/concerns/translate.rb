module Translate
  extend ActiveSupport::Concern

  def tg(key, category=nil, options = {})
    category = "misc" unless category
    I18n.t("global.#{category}.#{key}", options)
  end

  def tgm(key, options = {})
    ActionController::Base.helpers.sanitize tg(key, :misc, options)
  end

  def tgn(key, options = {})
    ActionController::Base.helpers.sanitize tg(key, :notice, options)
  end

  def tf(model, key, options = {})
    I18n.t("activerecord.attributes.#{model.name.underscore}.#{key}", options)
  end
end
