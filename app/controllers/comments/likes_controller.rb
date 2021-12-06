class Comments::LikesController < ::LikesController
  before_action :set_likeable, only: %i[create]

  private

  def set_likeable
    @likeable = Comment.find(params[:comment_id])
  end
end
