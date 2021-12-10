class AddCommentableCountToJournals < ActiveRecord::Migration[6.1]
  def change
    add_column :journals, :commentable_count, :integer
  end
end
