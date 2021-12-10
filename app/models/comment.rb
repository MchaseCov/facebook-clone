class Comment < ApplicationRecord
  include ActionView::RecordIdentifier
  extend ActiveSupport::Concern
  # Comment Schema:
  # body:               text
  # actor_id:           integer
  # commentable_id:     integer
  # commentable_type:   string
  # parent_id:          integer
  # timestamps:         datetime
  #
  #
  # Callbacks
  after_create_commit do
    current_user = Current.user # Turbo Stream needs Devise current_user passed as a local for partials that call
                                # for it, such as the "if X == current_user" checks for displaying different buttons.
                                #
    broadcast_prepend_later_to [commentable, :comments], locals: { current_user: current_user },
                                                         target: "#{dom_id(parent || commentable)}_comments",
                                                         partial: 'comments/comment_with_replies'
  end

  after_update_commit do
    current_user = Current.user
    broadcast_replace_to self, locals: { current_user: current_user }
  end

  after_destroy_commit do
    broadcast_remove_to self
    broadcast_remove_to self, target: "#{dom_id(self)}_with_comments"
  end

  after_create_commit :create_notification

  # Scopes
  scope :newest_first, -> { order(created_at: :desc) }
  scope :oldest_first, -> { order(created_at: :asc) }
  scope :most_likes_first, -> { order(:likeable_count) }
  scope :least_likes_first, -> { order(likeable_count: :desc) }
  # Validations
  validates :body, presence: true, length: { maximum: 1_000 }

  # Associations
  #   Polymorphic [Journals]
  belongs_to :commentable, polymorphic: true
  #   Comments (self)
  has_many :comments, -> { includes(:likes, :comment_author, comments: :comments) },
           foreign_key: :parent_id,
           dependent: :destroy

  belongs_to :parent, class_name: :Comment,
                      optional: true
  #   Likes
  has_many :likes, as: :likeable,
                   dependent: :destroy
  #   Users
  belongs_to :comment_author, class_name: :User,
                              foreign_key: :actor_id,
                              inverse_of: :authored_comments
  #   Notifications
  has_many :notifications, as: :notifiable,
                           dependent: :destroy

  # Methods
  def self.search(search)
    return unless search

    case search
    when 'Newest First'
      newest_first
    when 'Oldest First'
      oldest_first
    when 'Most Likes First'
      most_likes_first
    when 'Least Likes First'
      least_likes_first
    else
      newest_first
    end
  end

  private

  def create_notification
    if !self.parent_id.nil? # Commenting on a comment
      return if parent.comment_author == comment_author # No Notif if comment on own Comment

      parent.comment_author.recieved_notifications.create(actor: comment_author,
                                                          action: "replied to your Comment
                                                                  on #{commentable.journal_author.nick_name}'s Journal",
                                                          notifiable: self)
    elsif commentable_type == 'Journal'
      return if commentable.journal_author == comment_author # No Notif if comment on own Journal

      commentable.journal_author.recieved_notifications.create(actor: comment_author,
                                                               action: 'commented on your Journal',
                                                               notifiable: self)
    end
  end
end
