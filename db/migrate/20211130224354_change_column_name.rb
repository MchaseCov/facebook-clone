class ChangeColumnName < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :full_name, :name
  end
end
