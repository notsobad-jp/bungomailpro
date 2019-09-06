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

ActiveRecord::Schema.define(version: 2019_09_06_115037) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "books", id: :bigint, default: nil, force: :cascade do |t|
    t.string "title", null: false
    t.string "author", null: false
    t.bigint "author_id"
    t.bigint "file_id"
    t.text "footnote"
    t.integer "chapters_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "words_count", default: 0
    t.string "beginning"
    t.integer "access_count", default: 0
    t.string "category_id"
    t.string "group"
    t.index ["access_count"], name: "index_books_on_access_count"
    t.index ["group"], name: "index_books_on_group"
    t.index ["words_count"], name: "index_books_on_words_count"
  end

  create_table "campaigns", force: :cascade do |t|
    t.integer "sendgrid_id"
    t.uuid "user_id", null: false
    t.string "title", null: false
    t.text "plain_content", null: false
    t.datetime "send_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sendgrid_id"], name: "index_campaigns_on_sendgrid_id", unique: true
    t.index ["user_id"], name: "index_campaigns_on_user_id"
  end

  create_table "categories", id: :string, force: :cascade do |t|
    t.string "name", null: false
    t.integer "range_from"
    t.integer "range_to"
    t.integer "books_count", default: 0
    t.index ["range_from"], name: "index_categories_on_range_from"
  end

  create_table "channel_books", force: :cascade do |t|
    t.uuid "channel_id", null: false
    t.bigint "book_id", null: false
    t.integer "index", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_channel_books_on_book_id"
    t.index ["channel_id", "book_id"], name: "index_channel_books_on_channel_id_and_book_id", unique: true
    t.index ["channel_id", "index"], name: "index_channel_books_on_channel_id_and_index", unique: true
    t.index ["channel_id"], name: "index_channel_books_on_channel_id"
    t.index ["index"], name: "index_channel_books_on_index"
  end

  create_table "channels", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "status", default: "private", null: false, comment: "IN (private public streaming)"
    t.integer "books_count", default: 0, null: false
    t.integer "subscribers_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "default", default: false, null: false
    t.string "hashtag"
    t.string "from_name"
    t.string "from_email"
    t.index ["user_id", "default"], name: "index_channels_on_user_id_and_default", unique: true, where: "(\"default\" = true)"
    t.index ["user_id"], name: "index_channels_on_user_id"
  end

  create_table "chapters", id: false, force: :cascade do |t|
    t.bigint "book_id", null: false
    t.integer "index", null: false
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url"
    t.index ["book_id", "index"], name: "index_chapters_on_book_id_and_index", unique: true
    t.index ["book_id"], name: "index_chapters_on_book_id"
    t.index ["index"], name: "index_chapters_on_index"
  end

  create_table "charges", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "customer_id", null: false
    t.string "brand", null: false, comment: "IN (American Express, Diners Club, Discover, JCB, MasterCard, UnionPay, Visa, Unknown)"
    t.integer "exp_month", null: false
    t.integer "exp_year", null: false
    t.string "last4", null: false
    t.string "subscription_id"
    t.string "status", comment: "IN (trialing active past_due canceled unpaid)"
    t.datetime "trial_end"
    t.datetime "cancel_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_charges_on_customer_id", unique: true
    t.index ["subscription_id"], name: "index_charges_on_subscription_id", unique: true
    t.index ["user_id"], name: "index_charges_on_user_id", unique: true
  end

  create_table "comments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "subscription_id", null: false
    t.bigint "book_id", null: false
    t.integer "index", null: false
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_comments_on_book_id"
    t.index ["subscription_id", "book_id", "index"], name: "index_comments_on_subscription_id_and_book_id_and_index", unique: true
    t.index ["subscription_id"], name: "index_comments_on_subscription_id"
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

  create_table "feeds", force: :cascade do |t|
    t.uuid "subscription_id", null: false
    t.bigint "book_id", null: false
    t.integer "index", null: false
    t.datetime "delivered_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_feeds_on_book_id"
    t.index ["delivered_at"], name: "index_feeds_on_delivered_at"
    t.index ["subscription_id"], name: "index_feeds_on_subscription_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
  end

  create_table "subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "channel_id", null: false
    t.bigint "current_book_id"
    t.integer "next_chapter_index"
    t.integer "delivery_hour", default: 8, null: false
    t.date "next_delivery_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "footer"
    t.index ["channel_id"], name: "index_subscriptions_on_channel_id"
    t.index ["current_book_id"], name: "index_subscriptions_on_current_book_id"
    t.index ["user_id", "channel_id"], name: "index_subscriptions_on_user_id_and_channel_id", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.string "crypted_password"
    t.string "salt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "magic_login_token"
    t.datetime "magic_login_token_expires_at"
    t.datetime "magic_login_email_sent_at"
    t.string "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.string "category", comment: "IN (admin partner)"
    t.boolean "pixela_logging", default: false
    t.boolean "admin", default: false
    t.integer "list_id"
    t.index ["admin"], name: "index_users_on_admin"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["magic_login_token"], name: "index_users_on_magic_login_token"
    t.index ["remember_me_token"], name: "index_users_on_remember_me_token"
  end

  add_foreign_key "books", "categories"
  add_foreign_key "campaigns", "users"
  add_foreign_key "channel_books", "books"
  add_foreign_key "channel_books", "channels"
  add_foreign_key "channels", "users"
  add_foreign_key "chapters", "books"
  add_foreign_key "charges", "users"
  add_foreign_key "comments", "books"
  add_foreign_key "comments", "subscriptions"
  add_foreign_key "feeds", "books"
  add_foreign_key "feeds", "subscriptions"
  add_foreign_key "subscriptions", "books", column: "current_book_id"
  add_foreign_key "subscriptions", "channels"
  add_foreign_key "subscriptions", "users"
end
