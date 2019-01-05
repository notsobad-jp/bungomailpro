# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_01_03_034411) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "books", id: :bigint, default: nil, force: :cascade do |t|
    t.string "title", null: false
    t.string "author", null: false
    t.bigint "author_id", null: false
    t.bigint "file_id"
    t.text "footnote"
    t.integer "chapters_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "channel_books", force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.bigint "book_id", null: false
    t.integer "index", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "delivered", default: false, null: false
    t.index ["book_id"], name: "index_channel_books_on_book_id"
    t.index ["channel_id", "book_id"], name: "index_channel_books_on_channel_id_and_book_id", unique: true
    t.index ["channel_id", "index"], name: "index_channel_books_on_channel_id_and_index", unique: true
    t.index ["channel_id"], name: "index_channel_books_on_channel_id"
    t.index ["index"], name: "index_channel_books_on_index"
  end

  create_table "channels", force: :cascade do |t|
    t.string "token", null: false
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "description"
    t.boolean "public", default: false, null: false
    t.integer "books_count", default: 0, null: false
    t.integer "subscribers_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "last_chapter_id"
    t.bigint "next_chapter_id"
    t.integer "deliver_at", default: 8
    t.boolean "default", default: false, null: false
    t.index ["last_chapter_id"], name: "index_channels_on_last_chapter_id"
    t.index ["next_chapter_id"], name: "index_channels_on_next_chapter_id"
    t.index ["public"], name: "index_channels_on_public"
    t.index ["token"], name: "index_channels_on_token", unique: true
    t.index ["user_id", "default"], name: "index_channels_on_user_id_and_default", unique: true, where: "(\"default\" = true)"
    t.index ["user_id"], name: "index_channels_on_user_id"
  end

  create_table "chapters", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.integer "index", null: false
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id", "index"], name: "index_chapters_on_book_id_and_index", unique: true
    t.index ["book_id"], name: "index_chapters_on_book_id"
    t.index ["index"], name: "index_chapters_on_index"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "channel_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "default", default: false, null: false
    t.bigint "current_book_id"
    t.integer "current_chapter_index"
    t.integer "delivery_hour", default: 8, null: false
    t.date "next_delivery_date"
    t.index ["channel_id"], name: "index_subscriptions_on_channel_id"
    t.index ["current_book_id"], name: "index_subscriptions_on_current_book_id"
    t.index ["user_id", "channel_id"], name: "index_subscriptions_on_user_id_and_channel_id", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "token", null: false
    t.string "crypted_password"
    t.string "salt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "magic_login_token"
    t.datetime "magic_login_token_expires_at"
    t.datetime "magic_login_email_sent_at"
    t.string "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["magic_login_token"], name: "index_users_on_magic_login_token"
    t.index ["remember_me_token"], name: "index_users_on_remember_me_token"
    t.index ["token"], name: "index_users_on_token", unique: true
  end

  add_foreign_key "channel_books", "books"
  add_foreign_key "channel_books", "channels"
  add_foreign_key "channels", "chapters", column: "last_chapter_id"
  add_foreign_key "channels", "chapters", column: "next_chapter_id"
  add_foreign_key "channels", "users"
  add_foreign_key "chapters", "books"
  add_foreign_key "subscriptions", "books", column: "current_book_id"
  add_foreign_key "subscriptions", "channels"
  add_foreign_key "subscriptions", "users"
end
