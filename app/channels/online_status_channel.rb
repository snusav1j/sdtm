class OnlineStatusChannel < ApplicationCable::Channel
  def subscribed
    OnlineTracker.mark_online(current_user.id)
  end

  def unsubscribed
    OnlineTracker.mark_offline(current_user.id)
  end
end
