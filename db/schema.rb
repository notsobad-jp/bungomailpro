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

ActiveRecord::Schema.define(version: 2018_10_18_054904) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "books", id: :bigint, default: nil, force: :cascade do |t|
    t.string "title", null: false
    t.string "author", null: false
    t.bigint "author_id", null: false
    t.text "footnote"
  end

  create_table "chapters", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.integer "index", null: false
    t.text "text"
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

  create_table "deliveries", force: :cascade do |t|
    t.bigint "subscription_id", null: false
    t.integer "next_index", default: 1, null: false
    t.datetime "deliver_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deliver_at"], name: "index_deliveries_on_deliver_at"
    t.index ["subscription_id"], name: "index_deliveries_on_subscription_id", unique: true
  end

  create_table "list_books", force: :cascade do |t|
    t.bigint "list_id"
    t.bigint "book_id"
    t.integer "index", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_list_books_on_book_id"
    t.index ["index"], name: "index_list_books_on_index"
    t.index ["list_id", "book_id"], name: "index_list_books_on_list_id_and_book_id", unique: true
    t.index ["list_id", "index"], name: "index_list_books_on_list_id_and_index", unique: true
    t.index ["list_id"], name: "index_list_books_on_list_id"
  end

  create_table "lists", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "description"
    t.boolean "published", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["published"], name: "index_lists_on_published"
    t.index ["user_id"], name: "index_lists_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "book_id", null: false
    t.bigint "list_id"
    t.integer "index", default: 1, null: false
    t.integer "status", default: 1, null: false, comment: "1:waiting, 2:delivering, 3:finished"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_subscriptions_on_book_id"
    t.index ["index"], name: "index_subscriptions_on_index"
    t.index ["list_id"], name: "index_subscriptions_on_list_id"
    t.index ["status"], name: "index_subscriptions_on_status"
    t.index ["user_id", "book_id"], name: "index_subscriptions_on_user_id_and_book_id", unique: true
    t.index ["user_id", "index"], name: "index_subscriptions_on_user_id_and_index", unique: true
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

  add_foreign_key "chapters", "books"
  add_foreign_key "deliveries", "subscriptions"
  add_foreign_key "list_books", "books"
  add_foreign_key "list_books", "lists"
  add_foreign_key "lists", "users"
  add_foreign_key "subscriptions", "books"
  add_foreign_key "subscriptions", "lists"
  add_foreign_key "subscriptions", "users"
end
