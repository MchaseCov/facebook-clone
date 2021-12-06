class AddAvatarToGroups < ActiveRecord::Migration[6.1]
  def change
    add_column :groups, :avatar, :string
  end
end
