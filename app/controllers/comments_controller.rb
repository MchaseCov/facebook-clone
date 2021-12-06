class CommentsController < ApplicationController
  def new
    @comment = @commentable.comments.new
  end

  def create
    @comment = @commentable.comments.new(comment_params) do |c|
      c.comment_author = current_user
    end
    if @comment.save
      flash[:notice] = 'Your comment has successfully been created!'
      redirect_back(fallback_location: root_path)
    else
      render :new, alert: @comment.errors.full_messages
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
