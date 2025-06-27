class ApplicationController < ActionController::Base
  include  ApplicationHelper
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern
  before_action :create_super_user
  
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

end
