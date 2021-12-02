class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :permitted_params, if: :devise_controller?
  before_action :set_last_seen_at,
                if: -> { user_signed_in? && (current_user.last_seen_at.nil? || current_user.last_seen_at < 15.minutes.ago) }

  protected

  def permitted_params
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name nick_name avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name nick_name avatar banner])
  end

  private

  def set_last_seen_at
    current_user.update_column(:last_seen_at, Time.current)
  end
end
