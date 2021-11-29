class Friendship < ApplicationRecord
  # Friendship Schema:
  #
  # friend_a_id         bigint      index_friends_on_friend_a_id
  # friend_b_id         bigint      index_friends_on_friend_b_id
  # timestamps          datetime

  # Associations
  belongs_to :friend_a, class_name: :User
  belongs_to :friend_b, class_name: :User
end
