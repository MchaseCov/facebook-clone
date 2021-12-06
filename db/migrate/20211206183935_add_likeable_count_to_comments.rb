class AddLikeableCountToComments < ActiveRecord::Migration[6.1]
  def change
    add_column :comments, :likeable_count, :integer
  end
end
