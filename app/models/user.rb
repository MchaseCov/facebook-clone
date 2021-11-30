class User < ApplicationRecord
  # User Schema:
  # id:                 integer
  # email:              string
  # full_name:          string
  # nick_name:          string
  # timestamps:         datetime
  #
  # Devise
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Callbacks
  after_commit :add_default_avatar, on: %i[create update]
  after_commit :add_default_banner, on: %i[create update]

  # Validations
  validates :email, presence: true
  validates :full_name, presence: true
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
  #   Active Storage
  has_one_attached :avatar
  has_one_attached :banner

  # Methods
  def avatar_thumbnail(size = '125')
    avatar.variant(resize: "#{size}x#{size}!").processed
  end

  def banner_thumbnail(sizeh = '750', sizew = '480')
    banner.variant(resize: "#{sizeh}x#{sizew}!").processed
  end

  private

  def add_default_avatar
    return if avatar.attached?

    avatar.attach(
      io: File.open(
        Rails.root.join(
          'app', 'assets', 'images', 'default_avatar.jpg'
        )
      ),
      filename: 'default_avatar.jpg',
      content_type: 'image/jpg'
    )
  end

  def add_default_banner
    return if banner.attached?

    banner.attach(
      io: File.open(
        Rails.root.join(
          'app', 'assets', 'images', 'default_banner.jpg'
        )
      ),
      filename: 'default_banner.jpg',
      content_type: 'image/jpg'
    )
  end
end
