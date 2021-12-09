class CreateMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :messages do |t|
      t.text :body
      t.references :user, null: false, foreign_key: true, index: true
      t.references :conversation, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
