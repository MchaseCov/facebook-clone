class GroupsController < ApplicationController
  include GroupPrivacyHelper
  before_action :fetch_group, only: %i[show edit update destroy members]
  before_action :set_profile_owner, only: %i[show members]
  before_action :validate_user, only: %i[show members]
  before_action :validate_owner, only: %i[edit update destroy]

  def index
    @indexed_content = Group.user_authorized(current_user)
                            .includes(:users)
                            .includes(:creator)
                            .order(updated_at: :desc)
    render 'shared/main/index'
  end

  def show
    @journals = Journal.includes(:journal_author, :journalable, :likes).where(journalable: @profile_owner)
    render 'shared/profiles/show'
  end

  def members
    @indexed_content = @profile_owner.users
    render 'shared/profiles/index'
  end

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

  def toggle_membership
    @group = Group.find(params[:group_id])
    if request.put?
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
