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

  def create
    @comment = @commentable.comments.new(comment_params)
    @comment.comment_author = current_user
    @comment.parent_id = @parent&.id

    respond_to do |format|
      if @comment.save
        comment = Comment.new
        format.turbo_stream do
          if @parent
            # If reply is to another comment and successful, hide form
            render turbo_stream: turbo_stream.replace(dom_id_for_records(@parent, comment),
                                                      partial: 'comments/form',
                                                      locals: { comment: comment,
                                                                commentable: @parent,
                                                                current_user: current_user,
                                                                data: { comment_reply_target: :form },
                                                                class: 'd-none' })
          else
            render turbo_stream: turbo_stream.replace(dom_id_for_records(@commentable, comment),
                                                      partial: 'comments/form',
                                                      locals: { comment: comment,
                                                                commentable: @commentable,
                                                                current_user: current_user,
                                                                class: 'new-comment-region' })
          end
        end
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(dom_id_for_records(@parent || @commentable, @comment),
                                                    partial: 'comments/form',
                                                    locals: { comment: @comment,
                                                              commentable: @parent || @commentable,
                                                              current_user: current_user,
                                                              class: @parent.present? ? nil : 'new-comment-region' })
        end
      end
      format.html { redirect_to @commentable }
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
end
