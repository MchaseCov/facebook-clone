module ApplicationHelper
  def liked?(likeable, user)
    Like.where(actor_id: user.id, likeable: likeable).exists?
  end
end
