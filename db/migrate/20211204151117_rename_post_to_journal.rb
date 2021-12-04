class RenamePostToJournal < ActiveRecord::Migration[6.1]
  def change
    rename_table :posts, :journals
  end
end
