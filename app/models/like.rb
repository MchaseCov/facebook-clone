class Like < ApplicationRecord
  # Like Schema:
  # actor_id:           integer
  # likeable_id:        integer
  # likeable_type:      string
  # timestamps:         datetime
  #
  # Callbacks
  after_create_commit :create_notification

  # Scopes
  scope :existing_like, ->(likeable, user) { where(likeable: likeable, like_author: user) }
  # Validations
  # Associations
  #   Polymorphic [Journals, Comments]
  belongs_to :likeable, polymorphic: true,
                        counter_cache: :likeable_count
  #   Users
  belongs_to :like_author, class_name: :User,
                           foreign_key: :actor_id,
                           inverse_of: :authored_likes
  #   Notifications
  has_many :notifications, as: :notifiable,
                           dependent: :destroy

  # Methods

  private

  def create_notification
    case likeable_type
    when 'Journal'
      return if likeable.journal_author == like_author

      likeable.journal_author.recieved_notifications.create(actor: like_author,
                                                            action: 'liked your Journal',
                                                            notifiable: self)
    when 'Comment'
      return if likeable.comment_author == like_author

      likeable.comment_author.recieved_notifications.create(actor: like_author,
                                                            action: 'liked your Comment',
                                                            notifiable: self)
    end
  end
end
