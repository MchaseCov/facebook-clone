module ApplicationHelper
  def liked?(likeable, user)
    Like.where(actor_id: user.id, likeable: likeable).exists?
  end

  def new_messages
    Message.unread_messages(current_user).count
  end

  def recieved_friend_requests
    current_user.received_requests.count
  end

  def conversation_new_messages(user, conversation)
    Message.unread_messages(user).where(conversation: conversation).count
  end

  def unread_notifications
    current_user.unread_notifications.count
  end
end
