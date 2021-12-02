class UsersController < ApplicationController
  include GroupPrivacyHelper
  before_action :fetch_indexing_assets, only: %i[index friendships]
  before_action :fetch_profile_assets, only: %i[show groups friendships]
  before_action -> { fetch_visible_groups(@profile_owner) }, only: %i[show groups friendships]

  def index
    @indexed_content = User.all.order(current_sign_in_at: :desc)
    render 'shared/main/index'
  end

  def show
    render 'shared/profiles/show'
  end

  def groups
    @button_type = 'groups/member_button'
    @indexed_content = @groups
    @is_group = true
    render 'shared/profiles/index'
  end

  def friendships
    @indexed_content = @profile_owner.friends
    render 'shared/profiles/index'
  end

  private

  def fetch_profile_assets
    @profile_owner = User.find(params[:id] || params[:user_id])
    @banner_type = 'users/profile_banner'
  end

  def fetch_indexing_assets
    @button_type = 'users/friendship_button'
  end
end
