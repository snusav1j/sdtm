class MessagesController < ApplicationController
  before_action :authenticate_user!

  def index
    @recipient = User.find(params[:recipient_id])
    @messages = Message.get_messages(current_user, @recipient)
  end

  def create
    @message = current_user.sent_messages.build(message_params)

    if @message.save
      stream_key = stream_key_for(@message.sender_id, @message.recipient_id)

      # Отправляем сообщение всем, кто подписан на конкретную пару [sender, recipient]
      MessagesChannel.broadcast_to stream_key, message: render_message(@message, current_user)
    end
  end

  def load_messages
    @recipient = User.find(params[:recipient_id])
    @messages = Message.get_messages(current_user, @recipient)

    render partial: 'messages/messages_list', locals: { messages: @messages, current_user: current_user }
  end

  private

  def message_params
    params.require(:message).permit(:recipient_id, :body)
  end

  def render_message(message, viewer)
    render_to_string(
      partial: 'messages/message',
      locals: { message: message, current_user: viewer }
    )
  end

  def stream_key_for(user1_id, user2_id)
    ids = [user1_id, user2_id].sort
    "chat_#{ids[0]}_#{ids[1]}"
  end
end
