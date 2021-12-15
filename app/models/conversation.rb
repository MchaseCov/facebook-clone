class Conversation < ApplicationRecord
  include ActionView::RecordIdentifier
  extend ActiveSupport::Concern
  # Conversation Schema:
  # id:                                 integer
  # sender_id:                          integer
  # recipient_id:                       integer
  # [recipient_id, sender_id]:          index, unique: true
  # timestamps:                         datetime
  #
  # Callbacks
  # Scopes
  scope :between, lambda { |sender_id, recipient_id|
    where('(sender_id = ? AND recipient_id =?)
          OR (sender_id = ? AND recipient_id =?)',
          sender_id, recipient_id, recipient_id, sender_id)
  }
  # Validations
  validates_uniqueness_of :sender_id, scope: :recipient_id

  # Associations
  #   Messages
  has_many :messages, dependent: :destroy
  has_one :most_recent_message, -> { order 'created_at desc' },
          class_name: :Message
  #   Users
  belongs_to :sender, class_name: :User,
                      foreign_key: :sender_id,
                      inverse_of: :started_conversations
  belongs_to :recipient, class_name: :User,
                         foreign_key: :recipient_id,
                         inverse_of: :recieved_conversations
  # Methods
  #   Uses the between scope to check for an existing convo, or creates a new one.
  def self.fetch_conversation(sender_id, recipient_id)
    conversation = between(sender_id, recipient_id).first
    return conversation if conversation.present?

    create(sender_id: sender_id, recipient_id: recipient_id)
  end

  # Unlike Friendships, this table only has one listing per conversation and thus needs to check the relation
  def chat_partner(user)
    user == sender ?  recipient : sender
  end
end
