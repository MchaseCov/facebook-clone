class FriendRequest < ApplicationRecord
  # Friend Request Schema:
  #
  # requesting_user_id         bigint      index_friend_requests_on_recieving_user_id
  # recieving_user_id          bigint      index_friend_requests_on_requesting_user_id
  # timestamps                 datetime

  # Associations
  belongs_to :requesting_user, class_name: :User
  belongs_to :recieving_user, class_name: :User

  # Methods

end
