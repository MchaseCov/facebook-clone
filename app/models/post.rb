class Post < ApplicationRecord
  # Post Schema:
  # body:               text
  # actor_id:           integer
  # postable_id:        integer
  # postable_type:      string
  # timestamps:         datetime
  #
  # Callbacks
  # Scopes
  # Validations
  validates :post, presence: true, length: { maximum: 10_000 }

  # Associations
  #   Polymorphic
  #   [Users, Groups]
  belongs_to :postable, polymorphic: true
  #   Users
  belongs_to :post_author, class_name: 'User',
                           foreign_key: 'actor_id',
                           inverse_of: :created_posts
end
