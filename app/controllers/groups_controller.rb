class GroupsController < ApplicationController
  before_action :set_group, only: %i[show edit update destroy]
  before_action :set_group_nested, only: %i[users index_users]
  before_action :validate_owner, only: %i[edit update destroy]
  before_action :validate_user, only: %i[show index_users]

  def index
    @groups = Group.public_visibility
  end

  def show
  end

  def index_users
    @users = @group.users.all
  end

  def new
    @group = current_user.created_groups.build
  end

  def edit
  end

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
    @group = Group.find(params[:id])
  end

  def set_group_nested
    @group = Group.find(params[:group_id])
  end

  def validate_owner
    head(403) unless @group.creator == current_user
  end

  def validate_user
    return unless @group.private == true

    head(403) unless @group.users.include?(current_user) || @group.creator == current_user
  end

  def group_params
    params.require(:group).permit(:name, :description, :private, :avatar, :banner)
  end
end
