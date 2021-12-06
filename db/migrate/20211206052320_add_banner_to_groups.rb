class AddBannerToGroups < ActiveRecord::Migration[6.1]
  def change
    add_column :groups, :banner, :string
  end
end
