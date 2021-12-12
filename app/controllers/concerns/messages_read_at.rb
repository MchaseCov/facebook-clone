module MessagesReadAt
  def mark_messages_as_read(conversation, user)
    conversation.messages.unread_messages(user).each do |message|
      message.update_attribute(:read_at, DateTime.now)
    end
  end
end
