class RenamePostsIndexToJournalIndex < ActiveRecord::Migration[6.1]
  def change
    rename_index :journals, 'index_posts_on_postable', 'index_journals_on_journalable'
  end
end
