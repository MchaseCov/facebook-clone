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

  # Validations
  validates :email, presence: true
  validates :full_name, presence: true
  validates :nick_name, presence: true, length: { maximum: 50 }

  # Associations
  has_many :sent_friend_request, class_name: 'Friendship',
                                 foreign_key: 'sent_by_id',
                                 inverse_of: 'sent_by',
                                 dependent: :destroy
  has_many :recieved_friend_request, class_name: 'Friendship',
                                     foreign_key: 'sent_to_id',
                                     inverse_of: 'sent_to',
                                     dependent: :destroy
  has_many :friends, -> { merge(Friendship.friends) },
           through: :sent_friend_request,
           source: :sent_to
  has_many :pending_requests, -> { merge(Friendship.not_friends) },
           through: :sent_friend_request,
           source: :sent_to
  has_many :received_requests, -> { merge(Friendship.not_friends) },
           through: :friend_request,
           source: :sent_by
end
