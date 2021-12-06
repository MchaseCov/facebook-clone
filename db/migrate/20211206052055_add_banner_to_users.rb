class AddBannerToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :banner, :string
  end
end
