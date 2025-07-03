module TranslateHelper

  def tgm(key, options = nil)
    options = {} unless options.is_a?(Hash)
    ActionController::Base.helpers.sanitize tg(key, category: :misc, **options)
  end

  def tn(key, options = nil)
    options = {} unless options.is_a?(Hash)
    ActionController::Base.helpers.sanitize tg(key, category: :notice, **options)
  end

  def tm(model, key, options = nil)
    options = {} unless options.is_a?(Hash)
    I18n.t("activerecord.attributes.#{model.name.underscore}.#{key}", **options)
  end

  private

  def tg(key, category: "misc", **options)
    I18n.t("global.#{category}.#{key}", **options)
  end

end
