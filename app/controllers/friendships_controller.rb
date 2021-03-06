# Controller for the creation of Friendships
# Each accepted friendship has two listings, inverse to each other.
class FriendshipsController < ApplicationController
  include FriendshipsHelper
  include GroupPrivacyHelper

  before_action :fetch_recieving_user, only: %i[create]
  before_action :fetch_existing_request, only: %i[accept_friend_request decline_friend_request]
  before_action :fetch_existing_friendship, only: %i[destroy]

  # Creates a new friendship entry between the two users
  def create
    return if friend_request_sent?(@recieving_user)
    return if friend_request_recieved?(@recieving_user)

    @new_friendship = current_user.friend_sent.build(sent_to_id: @recieving_user.id)
    if @new_friendship.save
      flash[:notice] = 'Friend Request Sent!'
    else
      flash[:error] = 'Friend Request Failed!'
    end
    redirect_to @recieving_user
  end

  # Sets friendship status to true & creates an inverse friendship relation
  def accept_friend_request
    return unless @friendship

    @friendship.status = true
    if @friendship.save
      flash[:notice] = 'Friend Request Accepted!'
      @friendship.create_notification
      @friendship_inverse = current_user.friend_sent.build(sent_to_id: params[:user_id], status: true)
      @friendship_inverse.save
    else
      flash[:error] = 'Could not accept request!'
    end
    redirect_back(fallback_location: root_path)
  end

  # Declines friend request, deleting friendship entry
  def decline_friend_request
    return unless @friendship

    @friendship.destroy
    flash[:notice] = 'Friend Request Declined!'
    redirect_back(fallback_location: root_path)
  end

  def destroy
    return unless @friendship && @friendship_inverse

    @friendship.destroy
    @friendship_inverse.destroy
    flash[:notice] = 'Successfully Unfriended!'
    redirect_back(fallback_location: root_path)
  end

  # Lists all friend requests for a user
  def index
    @received_requests = current_user.received_requests.order(name: :desc)
    @pending_requests = current_user.pending_requests.order(name: :desc)
  end

  private

  def fetch_recieving_user
    @recieving_user = User.find(params[:user_id])
  end

  def fetch_existing_request
    @friendship = Friendship.find_by(sent_by_id: params[:user_id], sent_to_id: current_user.id, status: false)
  end

  def fetch_existing_friendship
    @friendship = Friendship.find_by(sent_by_id: params[:user_id], sent_to_id: current_user.id, status: true)
    @friendship_inverse = Friendship.find_by(sent_by_id: current_user.id, sent_to_id: params[:user_id], status: true)
  end
end
