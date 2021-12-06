class Users::JournalsController < ::JournalsController
  include GroupPrivacyHelper
  before_action :fetch_profile_owner, only: %i[show]
  before_action :set_journalable, only: %i[new create]
  before_action -> { fetch_visible_groups(@profile_owner) }, only: %i[show]

  def show
    @journal = Journal.find(params[:id])
    @comments = @journal.comments.includes(:comment_author, comments: [:comment_author, {comments: :comments }]).references(:comments)
  end

  private

  def set_journalable
    @journalable = User.find(params[:user_id] || params[:id])
    @url = user_journals_path
  end

  def fetch_profile_owner
    @profile_owner = User.find(params[:user_id])
  end
end
