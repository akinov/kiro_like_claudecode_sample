class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :title, null: false, limit: 100
      t.text :content, null: false, limit: 1000
      t.string :author_name, null: false, limit: 50

      t.timestamps
    end

    add_index :posts, :created_at, order: :desc
  end
end
