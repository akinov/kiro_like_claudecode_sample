# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_02_030224) do
  create_table "posts", force: :cascade do |t|
    t.string "title", limit: 100, null: false
    t.text "content", limit: 1000, null: false
    t.string "author_name", limit: 50, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_posts_on_created_at", order: :desc
  end

  create_table "replies", force: :cascade do |t|
    t.integer "post_id", null: false
    t.text "content", limit: 1000, null: false
    t.string "author_name", limit: 50, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id", "created_at"], name: "index_replies_on_post_id_and_created_at"
    t.index ["post_id"], name: "index_replies_on_post_id"
  end

  add_foreign_key "replies", "posts"
end
