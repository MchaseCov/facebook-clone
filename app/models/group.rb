class Group < ApplicationRecord
  # Group Schema:
  # id:                 integer
  # name:               string
  # creator_id:         integer
  # description:        text
  # private:            boolean     default: false
  # avatar:             string (Carrierwave gem)
  # banner:             string (Carrierwave gem)
  # timestamps:         datetime
  #
  # Callbacks
  after_commit :add_creator_to_users, on: :create

  # Carrierwave
  mount_uploader :avatar, AvatarUploader
  mount_uploader :banner, BannerUploader

  # Scopes
  alias_attribute :nick_name, :name
  scope :public_visibility, -> { where('private =?', false) }
  scope :private_visibility, -> { where('private =?', true) }
  scope :recently_created, -> { where('created_date >= :date', date: 1.week.ago) }
  scope :includes_user, ->(user) { where(id: user.groups.pluck(:id)) }
  scope :excludes_user, ->(user) { where.not(id: user.groups.pluck(:id)) }

  # Validations
  validates :name, presence: true,
                   length: { maximum: 50 }
  validates :description, presence: true,
                          length: { maximum: 255 }
  validates :creator_id, presence: true

  # Associations
  #   Journals
  has_many :journals, as: :journalable
  #   User
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  has_and_belongs_to_many :users

  # Methods

  def self.user_authorized(user)
    public_visibility.or(includes_user(user))
  end

  def self.user_unauthorized(user)
    private_visibility.excludes_user(user)
  end

  private

  def add_creator_to_users
    users << (User.where(id: creator_id))
  end
end
