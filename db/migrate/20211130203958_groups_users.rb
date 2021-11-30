class GroupsUsers < ActiveRecord::Migration[6.1]
  create_table :groups_users, id: false do |t|
    t.belongs_to :group
    t.belongs_to :user
  end
end
