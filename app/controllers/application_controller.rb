class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :permitted_params, if: :devise_controller?
  before_action :set_last_seen_at,
                if: lambda {
                      user_signed_in? && (current_user.last_seen_at.nil? || current_user.last_seen_at < 15.minutes.ago)
                    }
  before_action :fetch_user_groups, if: -> { user_signed_in? }
  around_action :set_current_user, if: -> { user_signed_in? }

  protected

  # Devise registration params
  def permitted_params
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name nick_name avatar avatar_cache])
    devise_parameter_sanitizer.permit(:account_update,
                                      keys: %i[name nick_name avatar avatar_cache banner banner_cache])
  end

  # Turbo broadcast compatibility.
  def set_current_user
    Current.user = current_user
    yield
  ensure
    # to address the thread variable leak issues in Puma/Thin webserver
    Current.user = nil
  end

  private

  # For tracking online timing on various user listing pages
  def set_last_seen_at
    current_user.update_column(:last_seen_at, Time.current)
  end

  # Keeps the sidebar updated with your groups!
  def fetch_user_groups
    @sidebar_groups = Group.where(id: current_user.groups.pluck(:id)).limit(5).order(created_at: :desc)
  end
end
