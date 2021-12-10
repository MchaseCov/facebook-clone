class NotificationsController < ApplicationController
  include ActionView::Helpers::TextHelper # for 'pluralize'

  def index
    @notifications = current_user.unread_notifications.includes(:notifiable, :actor).order(created_at: :desc)
  end

  def read
    i = update_notifications(DateTime.now, current_user.unread_notifications)
    flash[:notice] = "Marked #{pluralize(i, 'notification')} as read!"
    redirect_back(fallback_location: notifications_path)
  end

  def read_all
    current_user.unread_notifications.update_all(read_at: DateTime.now)
    flash[:notice] = 'Marked all notifications as read!'
    redirect_back(fallback_location: notifications_path)
  end
=begin
  def unread
    i = update_notifications(nil, current_user.read_notifications)
    flash[:notice] = "Marked #{pluralize(i, 'notification')} as unread!"
    redirect_back(fallback_location: notifications_path)
  end

  def destroy
    current_user.read_notifications.destroy_all
    flash[:notice] = 'Deleted all past notifications!'
    redirect_back(fallback_location: notifications_path)
  end
=end

  private

  def update_notifications(time, notifications)
    i = 0
    params[:ids]&.each do |id|
      notification = notifications.find_by(id: id)
      next if notification.nil?

      notification.update_attribute(:read_at, time)
      i += 1
    end
    i
  end
end
