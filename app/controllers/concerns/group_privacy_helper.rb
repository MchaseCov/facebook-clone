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

  def fetch_visible_groups(grouped_member)
    @groups = if grouped_member == current_user
                grouped_member.groups
              else
                public_or_included(grouped_member.groups)
              end
  end
end
