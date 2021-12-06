class Comment < ApplicationRecord
  # Comment Schema:
  # body:               text
  # actor_id:           integer
  # commentable_id:      integer
  # commentable_type:   string
  # timestamps:         datetime
  #
  # Callbacks
  # Scopes
  default_scope { order(created_at: :desc) }
  # Rails 6.1 does not have support for eagerly loaded ActiveStorage variants and as a result,
  # listing these variants results in a N+1 query. More information about this can be found at the following PR:
  # https://github.com/rails/rails/pull/40842
  # The following scope is to eagerly load variant records and the respective attachments and blobs
  # of those records. This scope solve this alongside a method that is appended during initialization.
  # This includes() statement & associated config/initialize/EagerLoadVariant.rb file come from:
  # https://bill.harding.blog/2021/04/15/applying-a-text-watermark-with-rails-activestorage-6-1/
  scope :load_avatars, -> {
                         includes(
                           comment_author: {
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
  validates :body, presence: true, length: { maximum: 1_000 }

  # Associations
  #   Polymorphic
  #   [Journals, Comments]
  belongs_to :commentable, polymorphic: true
  #   Comments (self)
  has_many :comments,
           as: :commentable,
           dependent: :destroy
  #   Users
  belongs_to :comment_author, class_name: :User,
                              foreign_key: :actor_id,
                              inverse_of: :authored_comments
  # Methods
end
