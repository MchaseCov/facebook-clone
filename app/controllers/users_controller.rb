class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    # Temporary code to test friend requests
    @recieved_requests = Friendship.where(sent_to_id: current_user.id, status: false)
  end
end
