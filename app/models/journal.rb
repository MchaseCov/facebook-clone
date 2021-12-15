class Journal < ApplicationRecord
  # Journal Schema:
  # body:               text
  # actor_id:           integer
  # journalable_id:     integer
  # journalable_type:   string
  # image:              string (Carrierwave gem)
  # timestamps:         datetime
  #
  # Callbacks
  after_create_commit :create_notification

  # Carrierwave
  mount_uploader :image, ImageUploader

  # Scopes
  scope :by_friend, -> { where('post_author == :friends', friends: 1.week.ago) }
  scope :by_user, ->(user) { where(journal_author: user) }

  # Validations
  validates :body, presence: true, length: { maximum: 10_000 }

  # Associations
  #   Polymorphic [Users, Groups]
  belongs_to :journalable, polymorphic: true,
                           touch: true
  #   Comments
  has_many :comments, as: :commentable,
                      dependent: :destroy
  #   Likes
  has_many :likes, as: :likeable,
                   dependent: :destroy
  #   Notifications
  has_many :notifications, as: :notifiable,
                           dependent: :destroy
  #   Users
  belongs_to :journal_author, class_name: :User,
                              foreign_key: :actor_id,
                              inverse_of: :authored_journals

  # Methods
  def self.social_circle(user)
    by_user(user).or(where(journal_author: user.friends))
  end

  private

  def create_notification
    return if journalable == journal_author # No notification on self posts

    if journalable_type == 'User'
      journalable.recieved_notifications.create(actor: journal_author,
                                                action: 'posted on your Profile',
                                                notifiable: self)
    elsif journalable_type == 'Group' && journalable.creator != journal_author
      journalable.creator.recieved_notifications.create(actor: journal_author,
                                                        action: "posted on #{journalable.name}",
                                                        notifiable: self)
    end
  end
end
