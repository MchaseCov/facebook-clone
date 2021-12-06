class Comments::CommentsController < ::CommentsController
  before_action :set_commentable, only: %i[new create]

  private

  def set_commentable
    @commentable = Comment.find(params[:comment_id])
    @url = comment_comments_path
  end
end
