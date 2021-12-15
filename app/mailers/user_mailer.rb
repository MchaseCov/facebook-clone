class UserMailer < ApplicationMailer
  default from: 'friendsydeveloper@gmail.com'

  def new_user_email
    @user = params[:user]
    @url  = 'http://friendsy.herokuapp.com/users/edit'
    @method = @user.provider
    @profile = "http://friendsy.herokuapp.com/users/#{@user.id}"
    @admin_email = 'mchasecov@gmail.com'
    mail(to: @user.email, subject: 'Thank you for signing up for Friendsy!')
  end
end
