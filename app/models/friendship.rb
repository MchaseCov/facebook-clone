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
  # Associations

  belongs_to :sent_to, class_name: 'User', foreign_key: 'sent_to_id'
  belongs_to :sent_by, class_name: 'User', foreign_key: 'sent_by_id'
end
