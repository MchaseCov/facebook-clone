class GroupsController < ApplicationController
  include GroupPrivacyHelper
  before_action :set_group, only: %i[show edit update destroy users]
  before_action :validate_owner, only: %i[edit update destroy]
  before_action :validate_user, only: %i[show index_users]

  def index
    @indexed_content = Group.public_visibility
    @button_type = 'groups/member_button'
    render 'shared/main/index'
  end

  def show
    @profile_owner = @group
    @is_group = true
    @banner_type = 'groups/profile_banner'
    render 'shared/profiles/show'
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

  def users
    if request.put?
      @group.users << current_user
    elsif request.delete?
      @group.users.destroy current_user
    end
    redirect_back(fallback_location: root_path)
  end

  private

  def set_group
    @group = Group.find(params[:id] || params[:group_id])
  end

  def group_params
    params.require(:group).permit(:name, :description, :private, :avatar, :banner)
  end
end
