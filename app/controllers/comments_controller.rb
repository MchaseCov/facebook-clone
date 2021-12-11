# Controller for the creation and display of Journals (posts)
# Moduled with /journals/comments_controller & /comments/comments_controller
# PLEASE NOTE: /comments/comments_controller and controllers/comments_controller (you are here) are NOT THE SAME FILE!
class CommentsController < ApplicationController
  include ActionView::RecordIdentifier
  include RecordHelper
  before_action :fetch_comment, only: %i[edit update destroy]
  def new
    @comment = @commentable.comments.new
  end

  def show
    @comment = Comment.find(params[:id])
  end

  # Creation of a comment. Comments can be nested under other comments. Comments are broadcast instantly with Hotwire
  # Since Hotwire is new, I am giving line-by-line explanations
  def create
    @comment = @commentable.comments.new(comment_params)
    @comment.comment_author = current_user
    @comment.parent_id = @parent&.id # If commenting to a comment, assigns the existing comment as a parent
    if @comment.save
      comment = Comment.new # We make a new comment to 'refill' the reply area with a new reply form
      if @parent # If reply is to another comment and successful, replace & hide form
        turbo_stream_render(@parent, comment, 'd-none', { comment_reply_target: :form })
      else # If reply is to a Journal itself and successful, replace & hide form
        turbo_stream_render(@commentable, comment, 'new-comment-region', '')
      end
    else # If reply failed validation, reset form. If replying to a Journal itself, pass the new-comment-region class
      turbo_stream_render((@parent || @commentable), @comment, (@parent.present? ? nil : 'new-comment-region'), nil)
    end
  end

  def update
    if @comment.update(comment_params)
      redirect_to @comment
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy
    respond_to do |format|
      format.turbo_stream {}
      format.html { redirect_to @comment.commentable }
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end

  def fetch_comment
    @comment = current_user.authored_comments.find(params[:id])
  end

  # Method for rendering a new partial form after leaving a comment
  def turbo_stream_render(commentable, comment, htmlclass, data)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(dom_id_for_records(commentable, comment),
                                                  partial: 'comments/form',
                                                  locals: { comment: comment,
                                                            commentable: commentable,
                                                            current_user: current_user,
                                                            data: data,
                                                            class: htmlclass })
      end
      format.html { redirect_to commentable }
    end
  end
end
