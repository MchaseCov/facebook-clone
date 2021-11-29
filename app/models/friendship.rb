class Friendship < ApplicationRecord
  # Friendship Schema:
  # id:                 integer
  # sent_to_id:         integer
  # sent_by_id:         integer
  # status:             boolean
  # timestamps:         datetime
  #
  # Scopes
  scope :friends, -> { where('status =?', true) }
  scope :not_friends, -> { where('status =?', false) }

  # Validations
  validates :sent_to_id, uniqueness: { scope: :sent_by_id }
  validate :cannot_friend_self

  # Associations
  belongs_to :sent_to, class_name: 'User', foreign_key: 'sent_to_id'
  belongs_to :sent_by, class_name: 'User', foreign_key: 'sent_by_id'

  # Methods

  private

  def cannot_friend_self
    return unless sent_to_id == sent_by_id

    errors.add(:base, 'You cannot add yourself as a friend!')
  end
end
