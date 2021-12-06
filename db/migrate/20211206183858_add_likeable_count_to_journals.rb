class AddLikeableCountToJournals < ActiveRecord::Migration[6.1]
  def change
    add_column :journals, :likeable_count, :integer
  end
end
