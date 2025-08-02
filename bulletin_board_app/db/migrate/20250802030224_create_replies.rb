class CreateReplies < ActiveRecord::Migration[8.0]
  def change
    create_table :replies do |t|
      t.references :post, null: false, foreign_key: true
      t.text :content, null: false, limit: 1000
      t.string :author_name, null: false, limit: 50

      t.timestamps
    end

    add_index :replies, [ :post_id, :created_at ]
  end
end
