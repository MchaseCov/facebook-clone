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
  has_many :friend_requests, foreign_key: :requesting_user_id, dependent: :destroy

  has_many :requested_friends, through: :friend_requests, source: :recieving_user

  # The following came from https://stackoverflow.com/a/41978449

  #has_many :friendships, :foreign_key => "friend_a_id", :dependent => :destroy
  #has_many :friends, :through => :friendships, :dependent => :destroy, :source => 'friend_a'
  #has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_b_id", :dependent => :destroy
  #has_many :inverse_friends, :through => :inverse_friendships, :dependent => :destroy, :source => 'friend_a'

  def self.friends(user)
    Friendship.where(:friend_a_id == user.id).pluck(:friend_b_id) + Friendship.where(:friend_b_id == user.id).pluck(:friend_a_id)
  end


end
