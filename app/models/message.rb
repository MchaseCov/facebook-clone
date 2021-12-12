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
  # Callbacks
  after_create_commit :broadcast_message, :update_recipient_sidebar

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
    "sent #{time_ago_in_words(created_at)} ago"
  end

  def read_ago
    "#{time_ago_in_words(read_at)} ago"
  end

  private

  def broadcast_message
    broadcast_append_later_to conversation
  end

  def update_recipient_sidebar
    recipient_conversations = collect_recipient_conversations(recipient).to_a
    broadcast_update_later_to "user_#{recipient.id}_conversations", target: "user-#{recipient.id}-conversations",
                                                                    partial: 'conversations/conversation',
                                                                    collection: recipient_conversations,
                                                                    locals: { current_user: recipient }
  end

  def collect_recipient_conversations(recipient)
    recipient.total_conversations
             .includes(:most_recent_message)
             .order(updated_at: :desc)
  end
end
