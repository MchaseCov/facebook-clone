module FriendshipsHelper
  def friend_request_sent?(recieving_user)
    current_user.sent_friend_request.exists?(sent_to_id: recieving_user.id, status: false)
  end

  def friend_request_recieved?(sent_user)
    current_user.recieved_friend_request.exists?(sent_by_id: sent_user.id, status: false)
  end
end
