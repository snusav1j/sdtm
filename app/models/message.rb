class Message < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"

  validates :body, presence: true

  def self.get_messages(current_user, recipient)
    self.where(
      "(sender_id = :user_id AND recipient_id = :recipient_id) OR (sender_id = :recipient_id AND recipient_id = :user_id)",
      user_id: current_user.id, recipient_id: recipient.id
    ).order(:created_at)
  end
end
