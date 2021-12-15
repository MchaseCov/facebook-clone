class User < ApplicationRecord
  # User Schema:
  # id:                 integer
  # email:              string
  # name:               string
  # nick_name:          string
  # last_seen_at:       datetime
  # avatar:             string (Carrierwave gem)
  # banner:             string (Carrierwave gem)
  # provider:           string (OmniAuth)
  # uid:                string (OmniAuth)
  # timestamps:         datetime
  #
  # Devise
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[facebook github]

  # Callbacks
  after_create_commit do
    @admin_account = User.first
    add_default_friend
    add_default_notification
    add_default_message
    send_new_user_email
  end

  # Carrierwave
  mount_uploader :avatar, AvatarUploader
  mount_uploader :banner, BannerUploader

  # Scopes
  scope :recently_online, -> { where('last_seen_at >= :time', time: 3.hour.ago) }

  # Validations
  validates :email, presence: true
  validates :name, presence: true,
                   length: { maximum: 50 }
  validates :nick_name, presence: true,
                        length: { maximum: 16 }

  # Associations
  #   Comments
  has_many :authored_comments, class_name: :Comment,
                               foreign_key: :actor_id,
                               inverse_of: :comment_author,
                               dependent: :destroy
  #   Conversations
  has_many :started_conversations, class_name: :Conversation,
                                   foreign_key: :sender_id,
                                   inverse_of: :sender,
                                   dependent: :destroy
  has_many :recieved_conversations, class_name: :Conversation,
                                    foreign_key: :recipient_id,
                                    inverse_of: :recipient,
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
  #   Messages
  has_many :authored_messages, class_name: :Message,
                               foreign_key: :author_id,
                               inverse_of: :author,
                               dependent: :destroy
  has_many :recieved_messages, class_name: :Message,
                               foreign_key: :recipient_id,
                               inverse_of: :recipient,
                               dependent: :destroy
  #   Notifications
  has_many :recieved_notifications, class_name: :Notification,
                                    foreign_key: :recipient_id,
                                    inverse_of: :recipient,
                                    dependent: :destroy
  has_many :pushed_notifications, class_name: :Notification,
                                  foreign_key: :actor_id,
                                  inverse_of: :actor,
                                  dependent: :destroy
  has_many :unread_notifications, -> { merge(Notification.unread) },
           class_name: :Notification,
           foreign_key: :recipient_id,
           inverse_of: :recipient
  has_many :read_notifications, -> { merge(Notification.read) },
           class_name: :Notification,
           foreign_key: :recipient_id,
           inverse_of: :recipient

  # Methods
  #   Conversation tracking
  def total_conversations
    started_conversations.or(recieved_conversations)
  end

  #   Omniauth Related
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
      user.nick_name = (auth.info.nickname || auth.info.name)
      user.avatar = AvatarUploader.new
      user.avatar.download! auth.info.image
      user.save
    end
  end

  def self.new_with_session(params, session)
    if session['devise.user_attributes']
      new(session['devise.user_attributes'], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def password_required?
    super && provider.blank?
  end

  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end

  def has_no_password?
    encrypted_password.blank?
  end

  private

  def add_default_friend
    friendship = friend_sent.build(sent_to: @admin_account, status: true)
    friendship.save
    inverse_friendship = @admin_account.friend_sent.build(sent_to: self, status: true)
    inverse_friendship.save
  end

  def add_default_notification
    friendship = Friendship.where(sent_by: self).first
    recieved_notifications.create(actor: @admin_account,
                                  action: 'accepted your friend request!',
                                  notifiable: friendship)
  end

  def add_default_message
    conversation = Conversation.create(sender: @admin_account, recipient: self)
    welcome_message = 'Hello! Thank you for checking out my demo website, Friendsy. Check out the Github repo for a summary of features and to peek behind the scenes! :)'
    conversation.messages.create(author: @admin_account, recipient: self, body: welcome_message)
  end

  def send_new_user_email
    UserMailer.with(user: self).new_user_email.deliver_later
  end
end
