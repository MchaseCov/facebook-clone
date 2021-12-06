class Like < ApplicationRecord
  # Like Schema:
  # actor_id:           integer
  # likeable_id:        integer
  # likeable_type:      string
  # timestamps:         datetime
  #
  # Callbacks
  # Scopes
  scope :existing_like, ->(likeable, user) { where(likeable: likeable, like_author: user) }
  # Validations
  # Associations
  #   Polymorphic
  belongs_to :likeable, polymorphic: true,
                        counter_cache: :likeable_count
  #   Users
  belongs_to :like_author, class_name: :User,
                           foreign_key: :actor_id,
                           inverse_of: :authored_likes
  # Methods
end
