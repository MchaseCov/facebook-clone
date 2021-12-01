class UsersController < ApplicationController
  include GroupPrivacyHelper
  before_action :fetch_indexing_assets, only: %i[index]
  before_action :fetch_profile_assets, only: %i[show groups]

  def index
    @indexed_content = User.all
    render 'shared/main/index'
  end

  def show
    render 'shared/profiles/show'
  end

  def groups
    @button_type = 'groups/member_button'
    @indexed_content = if @profile_owner == current_user
                         @profile_owner.groups.order(private: :desc)
                       else
                         public_or_included(@profile_owner.groups)
                       end
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
