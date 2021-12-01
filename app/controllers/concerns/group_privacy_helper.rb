module GroupPrivacyHelper
  def validate_owner
    head(403) unless @group.creator == current_user
  end

  def validate_user
    @group ||= Group.find(params[:group_id])
    return unless @group.private == true

    head(403) unless @group.users.include?(current_user) || @group.creator == current_user
  end

  def public_or_included(g)
    g.public_visibility.or(g.where(id: current_user.groups.pluck(:id))).uniq
  end
end
