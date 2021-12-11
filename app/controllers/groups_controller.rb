# Controller for the creation, membership, and display of Groups
class GroupsController < ApplicationController
  include GroupPrivacyHelper
  before_action :fetch_group, only: %i[show edit update destroy members images]
  before_action :set_profile_owner, only: %i[show members edit images]
  before_action :validate_user, only: %i[show members images]
  before_action :validate_owner, only: %i[edit update destroy]

  # Index for all users using reusable grid partial
  def index
    @indexed_content = Group.user_authorized(current_user)
                            .includes(:users)
                            .includes(:creator)
                            .order(updated_at: :desc)
    render 'shared/main/index'
  end
  # _____________________________________________SHARED PROFILE LAYOUTS_____________________________________________ #
  # The usage of "profile_owner" as a nondescript variable is for reusability between user and group profile views.
  # This could potentially be taken a step further and have a Profile controller with multiple route modules

  # Group profile page. Facebook/Twitter hybrid style; shows self posts and recieved posts, but not directed to others
  def show
    @journals = @profile_owner.journals
                              .includes(:journal_author, :journalable, :likes)
                              .order(created_at: :desc)
    render 'shared/profiles/show'
  end

  # Index of a specific group's members using reusable grid partial.
  def members
    @indexed_content = @profile_owner.users
    render 'shared/profiles/index'
  end

  # Index of a specific groups's recieved image posts
  def images
    @journals = @profile_owner.journals
                              .where.not(image: nil)
                              .includes(:journal_author, :journalable, :likes)
                              .order(created_at: :desc)
    render 'shared/profiles/show'
  end

  # ______________________________________________GROUP CREATION RELATED____________________________________________ #

  def new
    @group = current_user.created_groups.build
  end

  def edit; end

  def create
    @group = current_user.created_groups.build(group_params)
    if @group.save
      redirect_to @group, notice: 'Group successfully created!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @group.update(group_params)
      redirect_to @group, notice: 'Group successfully updated!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_url, notice: 'Group successfully destroyed!'
  end

  # Public membership button request
  def toggle_membership
    @group = Group.find(params[:group_id])
    if request.put?
      return 403 if @group.private

      @group.users << current_user
    elsif request.delete?
      @group.users.destroy current_user
    end
    redirect_back(fallback_location: root_path)
  end

  private

  def fetch_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name, :description, :private, :avatar, :banner, :avatar_cache, :banner_cache)
  end

  def set_profile_owner
    @profile_owner = @group
  end
end
