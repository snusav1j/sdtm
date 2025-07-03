class Users::SessionsController < Devise::SessionsController

  # def create
  #   super do |user|
  #     #отметить пользователя онлайн
  #     OnlineTracker.mark_online(user) if user.present?
  #   end
  # end

  # def destroy
  #   super do |user|
  #     # отметить пользователя оффлйн
  #     OnlineTracker.mark_offline(current_user) if current_user.present?
  #   end
  # end
end
