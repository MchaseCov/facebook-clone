class GroupsController < ApplicationController
  before_action :set_group, only: %i[show edit update destroy]

  def index
    @groups = Group.all
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
    @group = Group.find(params[:group_id])
    if request.put?
      @group.users << current_user
    elsif request.delete?
      @group.users.destroy current_user
    end
    redirect_back(fallback_location: root_path)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = Group.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def group_params
    params.require(:group).permit(:name, :description, :private, :avatar, :banner)
  end
end
