class Message < ApplicationRecord
  # Message Schema:
  # id:                  integer
  # body:                text
  # author_id:           integer
  # recipient_id         integer
  # read_at              datetime
  # conversation_id:     integer
  # timestamps:          datetime
  #
  # Scopes
  scope :unread_messages, ->(user) { where(recipient: user, read_at: nil) }

  # Validations
  validates_presence_of :conversation_id, :author_id, :recipient_id
  validates :body, presence: true, length: { maximum: 1_000 }

  # Associations
  #   Conversations
  belongs_to :conversation, touch: true
  #   Users
  belongs_to :author, class_name: :User,
                      foreign_key: :author_id,
                      inverse_of: :authored_messages
  belongs_to :recipient, class_name: :User,
                         foreign_key: :recipient_id,
                         inverse_of: :recieved_messages
  # Methods
  include ActionView::Helpers::DateHelper
  def created_ago
    "#{time_ago_in_words(created_at)} ago"
  end
end
