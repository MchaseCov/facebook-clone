class Comments::CommentsController < ::CommentsController
  before_action :set_commentable, only: %i[new create]

  private

  def set_commentable
    @parent = Comment.find(params[:comment_id])
    @commentable = @parent.commentable # Even if the comment is nested, it still belongs to the main "commentable"!
  end
end
