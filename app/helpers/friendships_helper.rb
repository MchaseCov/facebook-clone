module FriendshipsHelper
  def friend_request_sent?(recieving_user)
    current_user.friend_sent.exists?(sent_to_id: recieving_user.id, status: false)
  end

  def friend_request_recieved?(sent_user)
    current_user.friend_recieved.exists?(sent_by_id: sent_user.id, status: false)
  end
end
