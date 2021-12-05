class Journal < ApplicationRecord
  # Journal Schema:
  # body:               text
  # actor_id:           integer
  # postable_id:        integer
  # postable_type:      string
  # timestamps:         datetime
  #
  # Callbacks
  # Scopes
  default_scope { order(created_at: :desc) }
  scope :by_friend, -> { where('post_author == :friends', friends: 1.week.ago) }
  scope :by_user, ->(user) { where(actor_id: user.id) }
  # Rails 6.1 does not have support for eagerly loaded ActiveStorage variants and as a result,
  # listing these variants results in a N+1 query. More information about this can be found at the following PR: 
  # https://github.com/rails/rails/pull/40842
  # The following scope is to eagerly load variant records and the respective attachments and blobs
  # of those records. This scope solve this alongside a method that is appended during initialization.
  # This includes() statement & associated config/initialize/EagerLoadVariant.rb file come from:
  # https://bill.harding.blog/2021/04/15/applying-a-text-watermark-with-rails-activestorage-6-1/
  scope :load_avatars, -> {
                         includes(
                           journal_author: {
                             avatar_attachment: {
                               blob: {
                                 variant_records: {
                                   image_attachment: :blob
                                 }
                               }
                             }
                           },
                           journalable: {
                             avatar_attachment: {
                               blob: {
                                 variant_records: {
                                   image_attachment: :blob
                                 }
                               }
                             }
                           }
                         )
                       }
  # Validations
  validates :body, presence: true, length: { maximum: 10_000 }

  # Associations
  #   Polymorphic
  #   [Users, Groups]
  belongs_to :journalable, polymorphic: true
  #   Users
  belongs_to :journal_author, class_name: :User,
                              foreign_key: :actor_id,
                              inverse_of: :authored_journals

  # Methods
  def self.social_circle(user)
    by_user(user).or(where(journal_author: user.friends))
  end
end
