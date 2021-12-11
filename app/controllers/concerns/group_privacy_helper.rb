# Reusable module for verifying group permissions
module GroupPrivacyHelper
  # For use when only the group owner should view a page (like settings)
  def validate_owner
    head(403) unless @group.creator == current_user
  end

  # For use to enforce private groups stay private
  def validate_user
    @group ||= Group.find(params[:group_id])
    return unless @group.private == true

    head(403) unless @group.users.include?(current_user) || @group.creator == current_user
  end

  # For use to make sure private groups are not listed in public listings on profiles/indexes
  def fetch_visible_groups(grouped_member)
    @groups = if grouped_member == current_user
                grouped_member.groups
              else
                grouped_member.groups.user_authorized(current_user)
              end
  end
end
