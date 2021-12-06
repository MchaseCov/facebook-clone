class LikesController < ApplicationController
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
