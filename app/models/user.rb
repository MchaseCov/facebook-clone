class User < ApplicationRecord
  # User Schema:
  # id:                 integer
  # email:              string
  # name:               string
  # nick_name:          string
  # last_seen_at:       datetime
  # avatar:             string (Carrierwave gem)
  # banner:             string (Carrierwave gem)
  # timestamps:         datetime
  #
  # Devise
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Carrierwave
  mount_uploader :avatar, AvatarUploader
  mount_uploader :banner, BannerUploader

  # Scopes
  scope :recently_online, -> { where('last_seen_at >= :time', time: 3.hour.ago) }

  # Validations
  validates :email, presence: true
  validates :name, presence: true
  validates :nick_name, presence: true,
                        length: { maximum: 50 }

  # Associations
  #   Comments
  has_many :authored_comments, class_name: :Comment,
                               foreign_key: :actor_id,
                               inverse_of: :comment_author,
                               dependent: :destroy
  #   Friendship
  has_many :friend_sent, class_name: :Friendship,
                         foreign_key: :sent_by_id,
                         inverse_of: :sent_by,
                         dependent: :destroy
  has_many :friend_recieved, class_name: :Friendship,
                             foreign_key: :sent_to_id,
                             inverse_of: :sent_to,
                             dependent: :destroy
  has_many :friends, -> { merge(Friendship.friends) },
           through: :friend_sent,
           source: :sent_to
  has_many :pending_requests, -> { merge(Friendship.not_friends) },
           through: :friend_sent,
           source: :sent_to
  has_many :received_requests, -> { merge(Friendship.not_friends) },
           through: :friend_recieved,
           source: :sent_by
  #   Groups
  has_many :created_groups, class_name: :Group,
                            foreign_key: :creator_id,
                            inverse_of: :creator,
                            dependent: :destroy
  has_and_belongs_to_many :groups
  #   Journals
  has_many :journals, as: :journalable,
                      dependent: :destroy
  has_many :authored_journals, class_name: :Journal,
                               foreign_key: :actor_id,
                               inverse_of: :journal_author,
                               dependent: :destroy
  #   Likes
  has_many :authored_likes, class_name: :Like,
                            foreign_key: :actor_id,
                            inverse_of: :like_author,
                            dependent: :destroy
end
