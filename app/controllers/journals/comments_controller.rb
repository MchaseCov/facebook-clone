class Journals::CommentsController < ::CommentsController
  before_action :set_commentable, only: %i[new create]

  private

  def set_commentable
    @commentable = Journal.find(params[:journal_id])
    @url = journal_comments_path
  end
end
