class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.references :actor, null: false, foreign_key: { to_table: :users }
      t.datetime :read_at, index: true, null: true
      t.string :action
      t.references :notifiable, polymorphic: true, null: false

      t.timestamps
    end
  end
end