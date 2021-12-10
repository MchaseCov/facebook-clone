class AddImageToJournals < ActiveRecord::Migration[6.1]
  def change
    add_column :journals, :image, :string
  end
end
