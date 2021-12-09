module ApplicationHelper
  def liked?(likeable, user)
    Like.where(actor_id: user.id, likeable: likeable).exists?
  end

  def new_messages
    Message.unread_messages(current_user).count
  end

  def conversation_new_messages(conversation)
    Message.unread_messages(current_user).where(conversation: conversation).count
  end
end
