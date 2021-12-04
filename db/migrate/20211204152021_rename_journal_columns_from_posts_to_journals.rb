class RenameJournalColumnsFromPostsToJournals < ActiveRecord::Migration[6.1]
  def change
    rename_column :journals, :postable_type, :journalable_type
    rename_column :journals, :postable_id, :journalable_id
  end
end
