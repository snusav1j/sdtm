class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :sent_messages, class_name: "Message", foreign_key: :sender_id, dependent: :destroy
  has_many :received_messages, class_name: "Message", foreign_key: :recipient_id, dependent: :destroy
  has_many :dice_games

  def has_change_rights?(user)
    user.dev? || self == user
  end

  def fullname
    if firstname.present? && lastname.present?
      firstname == lastname ? firstname : "#{firstname} #{lastname}"
    elsif lastname.present?
      lastname
    elsif firstname.present?
      firstname
    else
      "unnamed"
    end
  end

  def make_user_image_file(image_file)
    return unless image_file

    if image_name.present?
      old_path = Rails.root.join("public", "user_images", image_name)
      File.delete(old_path) if File.exist?(old_path)
      update(image_name: nil)
    end

    file_id = (Time.now.to_f * 1000).to_i
    new_name = "user_image_#{file_id}_#{id}#{File.extname(image_file.original_filename).downcase}"
    path = Rails.root.join("public", "user_images", new_name)

    File.open(path, 'wb') { |file| file.write(image_file.read) }
    update(image_name: new_name)
  end

  def user_image_url
    if image_name.present? && File.exist?(Rails.root.join("public", "user_images", image_name))
      "/user_images/#{image_name}"
    else
      default_user_image
    end
  end

  def default_user_image
    "/user_images/default_user_image.webp"
  end

  def has_user_image_file?
    image_name.present? && File.exist?(Rails.root.join("public", "user_images", image_name))
  end

  def registered_info
    "Зарегистрирован #{ApplicationController.helpers.small_date(created_at)}"
  end

  def user_role_id
    "(#{role}) ##{id}"
  end

  def valid_balance_for_dice?(bet_amount)
    balance.to_f >= bet_amount.to_f
  end

  def popup_user_balane(balance)
    update(balance: balance.to_f + self.balance.to_f)
  end

  def change_balance_by_dice(total_balance)
    update(balance: total_balance)
  end

  def dev?
    role == 'dev'
  end
end
