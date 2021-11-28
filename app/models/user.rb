class User < ApplicationRecord
  # User Schema:
  # id:                 integer
  # email:              string
  # full_name:          string
  # nick_name:          string
  # timestamps:         datetime
  #
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Validations
  validates :email, presence: true
  validates :full_name, presence: true
  validates :nick_name, presence: true, length: { maximum: 50 }

  # Associations

  # Friend Requests
  has_many :friend_requests,
  foreign_key: :requesting_user_id,
  dependent: :destroy

  has_many :requested_friends,
  through: :friend_requests,
  source: :recieving_user
end
