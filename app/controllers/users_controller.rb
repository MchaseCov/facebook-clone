# Controller for User profiles and listing all users. Devise handles user creation.
class UsersController < ApplicationController
  include GroupPrivacyHelper
  before_action :fetch_profile_owner, except: %i[index]
  before_action -> { fetch_visible_groups(@profile_owner) }, except: %i[index]
  # The groups are collected for every page to keep the group tab button's count tied to the visibility of groups
  # and not disclose any private group membership through a disparity in the number vs listings

  # Index for all users using reusable grid partial
  def index
    @indexed_content = User.includes(:friends, :received_requests, :pending_requests)
                           .references(:users)
                           .order('last_seen_at DESC NULLS LAST')
    render 'shared/main/index'
  end

  # _____________________________________________SHARED PROFILE LAYOUTS_____________________________________________ #
  # The usage of "profile_owner" as a nondescript variable is for reusability between user and group profile views.
  # This could potentially be taken a step further and have a Profile controller with multiple route modules

  # User profile page. Facebook/Twitter hybrid style; shows self posts and recieved posts, but not directed to others
  def show
    @journals = @profile_owner.journals
                              .includes(:journal_author, :likes)
                              .order(created_at: :desc)
    @recent_images = @profile_owner.authored_journals.where.not(image: nil).order(created_at: :desc).first(6)
    render 'shared/profiles/show'
  end

  # Index of a specific user's groups using reusable grid partial.
  def groups
    @indexed_content = @groups.eager_load(:users, :creator)
                              .order(created_at: :desc)
    render 'shared/profiles/index'
  end

  # Index of a specific user's friends using reusable grid partial.
  def friendships
    @indexed_content = @profile_owner.friends
                                     .includes(:friends)
                                     .order('last_seen_at DESC NULLS LAST')
    render 'shared/profiles/index'
  end

  # Index of a specific user's image posts
  def images
    @journals = @profile_owner.authored_journals
                              .where.not(image: nil)
                              .order(created_at: :desc)
    @recent_images = @journals.first(6)
    render 'shared/profiles/show'
  end

  private

  def fetch_profile_owner
    @profile_owner = User.find(params[:id])
  end
end
