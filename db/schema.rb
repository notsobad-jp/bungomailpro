# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_03_16_065959) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "aozora_books", id: :bigint, default: nil, force: :cascade do |t|
    t.string "title", null: false
    t.string "author", null: false
    t.bigint "author_id"
    t.bigint "file_id"
    t.text "footnote"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "words_count", default: 0
    t.string "beginning"
    t.integer "access_count", default: 0
    t.string "category_id"
    t.boolean "rights_reserved", default: false
    t.index ["access_count"], name: "index_aozora_books_on_access_count"
    t.index ["category_id"], name: "index_aozora_books_on_category_id"
    t.index ["words_count"], name: "index_aozora_books_on_words_count"
  end

  create_table "book_assignments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "guten_book_id", null: false
    t.uuid "user_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "feeds_count", default: 0
    t.index ["guten_book_id"], name: "index_book_assignments_on_guten_book_id"
    t.index ["status"], name: "index_book_assignments_on_status"
    t.index ["user_id"], name: "index_book_assignments_on_user_id"
  end

  create_table "campaign_groups", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.integer "count", null: false
    t.datetime "start_at", null: false
    t.integer "list_id", null: false
    t.integer "sender_id", null: false
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.index ["book_id"], name: "index_campaign_groups_on_book_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.integer "sendgrid_id"
    t.string "title", null: false
    t.text "content", null: false
    t.datetime "send_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "campaign_group_id", default: 1, null: false
    t.index ["campaign_group_id"], name: "index_campaigns_on_campaign_group_id"
    t.index ["sendgrid_id"], name: "index_campaigns_on_sendgrid_id", unique: true
  end

  create_table "categories", id: :string, force: :cascade do |t|
    t.string "name", null: false
    t.integer "range_from"
    t.integer "range_to"
    t.integer "books_count", default: 0
    t.index ["range_from"], name: "index_categories_on_range_from"
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
    t.integer "index", default: 1, null: false
    t.string "title"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "book_assignment_id", null: false
    t.datetime "scheduled_at"
    t.index ["book_assignment_id"], name: "index_feeds_on_book_assignment_id"
    t.index ["scheduled_at"], name: "index_feeds_on_scheduled_at"
  end

  create_table "guten_books", force: :cascade do |t|
    t.string "title", null: false
    t.string "author"
    t.boolean "rights_reserved", default: false
    t.string "language"
    t.bigint "downloads"
    t.integer "words_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "chars_count", default: 0, null: false
    t.integer "author_id"
    t.index ["author_id"], name: "index_guten_books_on_author_id"
  end

  create_table "guten_books_subjects", id: false, force: :cascade do |t|
    t.bigint "guten_book_id"
    t.string "subject_id"
    t.index ["guten_book_id", "subject_id"], name: "index_guten_books_subjects_on_guten_book_id_and_subject_id", unique: true
    t.index ["guten_book_id"], name: "index_guten_books_subjects_on_guten_book_id"
    t.index ["subject_id"], name: "index_guten_books_subjects_on_subject_id"
  end

  create_table "notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.datetime "send_at"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
  end

  create_table "subjects", id: :string, force: :cascade do |t|
    t.integer "books_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.string "crypted_password"
    t.string "salt"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.string "magic_login_token"
    t.datetime "magic_login_token_expires_at"
    t.datetime "magic_login_email_sent_at"
    t.string "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.string "timezone", default: "UTC"
    t.string "delivery_time", default: "07:00"
    t.integer "words_per_day", default: 400
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["magic_login_token"], name: "index_users_on_magic_login_token"
    t.index ["remember_me_token"], name: "index_users_on_remember_me_token"
  end

  add_foreign_key "aozora_books", "categories"
  add_foreign_key "book_assignments", "guten_books"
  add_foreign_key "book_assignments", "users"
  add_foreign_key "campaign_groups", "aozora_books", column: "book_id", on_update: :nullify, on_delete: :nullify
  add_foreign_key "campaigns", "campaign_groups"
  add_foreign_key "charges", "users"
  add_foreign_key "feeds", "book_assignments"
  add_foreign_key "guten_books_subjects", "guten_books"
  add_foreign_key "guten_books_subjects", "subjects"
end
