class Group < ApplicationRecord
  include AttachmentManager
  # Group Schema:
  # id:                 integer
  # name:               string
  # creator_id:         integer
  # description:        text
  # private:            boolean     default: false
  # timestamps:         datetime
  #
  # Callbacks
  before_create :add_default_avatar
  before_create :add_default_banner
  after_commit :add_creator_to_users, on: :create

  # Scopes
  scope :public_visibility, -> { where('private =?', false) }
  scope :private_visibility, -> { where('private =?', true) }
  scope :recently_created, -> { where('created_date >= :date', date: 1.week.ago) }

  # Validations
  validates :name, presence: true,
                   length: { maximum: 50 }
  validates :description, presence: true,
                          length: { maximum: 255 }
  validates :creator_id, presence: true
  validates :avatar, content_type: %i[png jpg jpeg],
                     size: { less_than: 2.megabytes, message: 'must be less than 2MB in size' }
  validates :banner, content_type: %i[png jpg jpeg],
                     size: { less_than: 3.megabytes, message: 'must be less than 3MB in size' },
                     aspect_ratio: :is_16_9

  # Associations
  #   Active Storage
  has_one_attached :avatar
  has_one_attached :banner
  #   Posts
  has_many :posts, as: :postable
  #   User
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  has_and_belongs_to_many :users

  # Methods

  def self.user_authorized(user)
    public_visibility.or(where(id: user.groups.pluck(:id)))
  end

  private

  def add_creator_to_users
    self.users << (User.where(id: self.creator_id))
  end
end
