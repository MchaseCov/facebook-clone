class Journal < ApplicationRecord
  # Journal Schema:
  # body:               text
  # actor_id:           integer
  # postable_id:        integer
  # postable_type:      string
  # timestamps:         datetime
  #
  # Callbacks
  # Scopes
  default_scope { order(created_at: :desc) }
  scope :by_friend, -> { where('post_author == :friends', friends: 1.week.ago) }
  scope :by_user, ->(user) { where(actor_id: user.id) }

  # Validations
  validates :body, presence: true, length: { maximum: 10_000 }

  # Associations
  #   Polymorphic
  #   [Users, Groups]
  belongs_to :journalable, polymorphic: true
  #   Users
  belongs_to :journal_author, class_name: :User,
                              foreign_key: :actor_id,
                              inverse_of: :authored_journals

  # Methods
  def self.social_circle(user)
    by_user(user).or(where(journal_author: user.friends))
  end
end
