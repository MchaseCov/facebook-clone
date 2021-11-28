class FriendRequestsController < ApplicationController
  before_action :authenticate_user!

  def create
    new_friend_request = FriendRequest.create(requesting_user_id: current_user.id, recieving_user_id: params[:recieving_user_id])
    if new_friend_request.save
      redirect_to profile_url(current_user), notice: 'Friend request sent!'
    else
      redirect_to profile_url(current_user), alert: "Could not send request!(#{new_friend_request.errors.full_messages.join(', ')}.)"
    end
  end

  def accept_request
    @friend_request = FriendRequest.find(params[:id])
    if @friend_request.recieving_user_id == current_user.id
      Friendship.create(friend_1: @friend_request.requesting_user, friend_2: @friend_request.recieving_user)
      @friend_request.destroy
      redirect_to profile_url(current_user), notice: 'Friend request accepted!'
    else
      redirect_to profile_url(current_user), alert: 'You are not authorized to edit that request!'
    end
  end
end
