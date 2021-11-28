class Friend < ApplicationRecord
  # Friend Schema:
  #
  # friend_1_id         bigint      index_friends_on_friend_1_id
  # friend_2_id         bigint      index_friends_on_friend_2_id
  # timestamps          datetime

  # Associations
  belongs_to :friend_1, class_name: :User
  belongs_to :friend_2, class_name: :User
end
