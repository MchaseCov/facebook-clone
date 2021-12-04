class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :permitted_params, if: :devise_controller?
  before_action :set_last_seen_at,
                if: -> { user_signed_in? && (current_user.last_seen_at.nil? || current_user.last_seen_at < 15.minutes.ago) }
  before_action :fetch_user_groups, if: -> { user_signed_in? }

  protected

  def permitted_params
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name nick_name avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name nick_name avatar banner])
  end

  private

  def set_last_seen_at
    current_user.update_column(:last_seen_at, Time.current)
  end

  def fetch_user_groups
    @sidebar_groups = Group.where(id: current_user.groups.pluck(:id)).includes(avatar_attachment: :blob).includes(:users).limit(5).references(:users).order(created_at: :desc)
  end
end
