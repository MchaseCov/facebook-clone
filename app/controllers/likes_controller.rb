# Controller for creation and deletion of user likes on posts/comments.
# Moduled with /journals/likes_controller & /comments/likes_controller
class LikesController < ApplicationController
  # Combined with the if statement, creates a 'toggle' for the like in one controller action.
  # I made this as an alternative idea to explore but realistically would be better off as 2 routes.
  def create
    redirect_back(fallback_location: root_path) and return if dislike(@likeable, current_user)

    @like = @likeable.likes.new do |p|
      p.like_author = current_user
    end
    if @like.save
      flash[:notice] = 'Your Like has been added!'
    else
      flash[:alert] = 'Like failed!'
    end
    redirect_back(fallback_location: root_path)
  end
end

private

def dislike(likeable, user)
  like = Like.where(likeable: likeable, like_author: user)
  return unless like.exists?

  like.destroy_all
  flash[:notice] = 'Like Removed!'
end
