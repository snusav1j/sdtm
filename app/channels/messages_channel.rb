class MessagesChannel < ApplicationCable::Channel
  def subscribed
    recipient_id = params[:recipient_id]
    sender_id = current_user.id

    ids = [sender_id, recipient_id.to_i].sort
    stream_for "chat_#{ids[0]}_#{ids[1]}"
  end

  def unsubscribed
  end
end
