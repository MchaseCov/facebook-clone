class AddColumnsToMessages < ActiveRecord::Migration[6.1]
  def change
    add_reference :messages, :recipient, index: true, null: false, foreign_key: { to_table: :users }
    add_column :messages, :read_at, :datetime, index: true, null: true
    rename_column :messages, :user_id, :author_id
  end
end
