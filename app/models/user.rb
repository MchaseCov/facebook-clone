class User < ApplicationRecord
  include AttachmentManager
  # User Schema:
  # id:                 integer
  # email:              string
  # name:               string
  # nick_name:          string
  # timestamps:         datetime
  # last_seen_at:      datetime
  #
  # Devise
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Callbacks
  before_create :add_default_avatar
  before_create :add_default_banner

  # Scopes
  scope :recently_online, -> { where('last_seen_at >= :time', time: 3.hour.ago) }
  scope :eager_friendship, -> { includes(:friends, :received_requests, :pending_requests).with_attached_avatar }

  # Validations
  validates :email, presence: true
  validates :name, presence: true
  validates :nick_name, presence: true,
                        length: { maximum: 50 }
  validates :avatar, content_type: %i[png jpg jpeg],
                     size: { less_than: 2.megabytes, message: 'must be less than 2MB in size' }
  validates :banner, content_type: %i[png jpg jpeg],
                     size: { less_than: 3.megabytes, message: 'must be less than 3MB in size' },
                     aspect_ratio: :is_16_9

  # Associations
  #   Friendship
  has_many :friend_sent, class_name: 'Friendship',
                         foreign_key: 'sent_by_id',
                         inverse_of: 'sent_by',
                         dependent: :destroy
  has_many :friend_recieved, class_name: 'Friendship',
                             foreign_key: 'sent_to_id',
                             inverse_of: 'sent_to',
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
  has_many :created_groups, class_name: 'Group',
                            foreign_key: 'creator_id',
                            inverse_of: 'creator',
                            dependent: :destroy
  has_and_belongs_to_many :groups
  #   Active Storage
  has_one_attached :avatar
  has_one_attached :banner
end
