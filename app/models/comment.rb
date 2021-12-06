class Comment < ApplicationRecord
  # Comment Schema:
  # body:               text
  # actor_id:           integer
  # commentable_id:     integer
  # commentable_type:   string
  # parent_id:          integer
  # timestamps:         datetime
  #
  # Callbacks
  # Scopes
  default_scope { order(created_at: :desc) }

  # Validations
  validates :body, presence: true, length: { maximum: 1_000 }

  # Associations
  #   Polymorphic
  #   [Journals, Comments]
  belongs_to :commentable, polymorphic: true
  belongs_to :parent_journal, class_name: :Journal,
                              foreign_key: :parent_id,
                              inverse_of: :children_comments,
                              optional: true
  #   Comments (self)
  has_many :comments, -> { includes(:comments, :likes) },
           as: :commentable,
           dependent: :destroy
  #   Likes
  has_many :likes, as: :likeable,
                   dependent: :destroy
  #   Users
  belongs_to :comment_author, class_name: :User,
                              foreign_key: :actor_id,
                              inverse_of: :authored_comments
  # Methods
end
