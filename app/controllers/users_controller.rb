class UsersController < ApplicationController
  include GroupPrivacyHelper
  before_action :fetch_profile_owner, only: %i[show groups friendships]
  before_action -> { fetch_visible_groups(@profile_owner) }, only: %i[show groups friendships]

  def index
    @indexed_content = User.includes(:friends, :received_requests, :pending_requests)
                           .with_attached_avatar
                           .order(last_seen_at: :asc)
    render 'shared/main/index'
  end

  def show
    @journals = Journal.includes(:journal_author, :journalable).where(journalable: @profile_owner)
    render 'shared/profiles/show'
  end

  def groups
    @indexed_content = @groups.eager_load(:users, :creator)
                              .with_attached_avatar
                              .order(created_at: :desc)
    render 'shared/profiles/index'
  end

  def friendships
    @indexed_content = @profile_owner.friends
                                     .eager_friendship
    render 'shared/profiles/index'
  end

  private

  def fetch_profile_owner
    @profile_owner = User.find(params[:id])
  end
end
