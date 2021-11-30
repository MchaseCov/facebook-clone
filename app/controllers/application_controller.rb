class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :permitted_params, if: :devise_controller?

  protected

  def permitted_params
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name nick_name avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name nick_name avatar banner])
  end
end
