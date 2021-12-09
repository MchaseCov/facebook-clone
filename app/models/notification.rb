class Notification < ApplicationRecord
  # Notification Schema:
  # id:                  integer
  # recipient_id:        integer
  # actor_id:            integer
  # read_at              datetime
  # action               string
  # notifiable_id:       integer
  # notifiable_type:     string
  # timestamps:          datetime
  #
  # Callbacks

  # Scopes
  scope :unread, -> { where(read_at: nil) }

  # Validations
  validates_presence_of :recipient_id, :actor_id, :action

  # Associations
  #   Polymorphic [Journals, Comments, Likes] (Messages & Friend Reqs have their own notification scopes)
  belongs_to :notifiable, polymorphic: true
  #   Users
  belongs_to :recipient, class_name: :User,
                         foreign_key: :recipient_id,
                         inverse_of: :recieved_notifications
  belongs_to :actor, class_name: :User,
                     foreign_key: :actor_id,
                     inverse_of: :pushed_notifications
  # Methods
end
