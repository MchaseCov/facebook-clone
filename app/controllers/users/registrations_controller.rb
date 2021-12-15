class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def update_resource(resource, params)
    if current_user.provider.nil?
      resource.update_with_password(params)
    else
      params.delete('current_password')
      resource.update_without_password(params)
    end
  end
end
