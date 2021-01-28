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

ActiveRecord::Schema.define(version: 2020_05_06_072749) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "aozora_books", force: :cascade do |t|
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
    t.string "first_edition"
    t.integer "published_at"
    t.string "character_type"
    t.boolean "juvenile", default: false, null: false
    t.index ["access_count"], name: "index_aozora_books_on_access_count"
    t.index ["category_id"], name: "index_aozora_books_on_category_id"
    t.index ["character_type"], name: "index_aozora_books_on_character_type"
    t.index ["juvenile"], name: "index_aozora_books_on_juvenile"
    t.index ["published_at"], name: "index_aozora_books_on_published_at"
    t.index ["words_count"], name: "index_aozora_books_on_words_count"
  end

  create_table "campaign_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "book_id", null: false
    t.integer "count", null: false
    t.datetime "start_at", null: false
    t.integer "list_id", null: false
    t.integer "sender_id", null: false
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.string "twitter_share_url"
    t.index ["book_id"], name: "index_campaign_groups_on_book_id"
  end

  create_table "campaigns", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "sendgrid_id"
    t.string "title", null: false
    t.text "content", null: false
    t.datetime "send_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "campaign_group_id", null: false
    t.index ["campaign_group_id"], name: "index_campaigns_on_campaign_group_id"
    t.index ["sendgrid_id"], name: "index_campaigns_on_sendgrid_id", unique: true
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

  create_table "guten_books", force: :cascade do |t|
    t.string "title", null: false
    t.string "author"
    t.boolean "rights_reserved", default: false
    t.string "language", default: "en"
    t.bigint "downloads", default: 0
    t.integer "words_count", default: 0, null: false
    t.integer "chars_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "author_id"
    t.string "category_id"
    t.string "beginning"
    t.integer "unique_words_count", default: 0
    t.integer "ngsl_words_count", default: 0
    t.float "ngsl_ratio"
    t.integer "birth_year"
    t.integer "death_year"
    t.index ["author_id"], name: "index_guten_books_on_author_id"
    t.index ["category_id"], name: "index_guten_books_on_category_id"
    t.index ["ngsl_ratio"], name: "index_guten_books_on_ngsl_ratio"
  end

  create_table "guten_books_subjects", id: false, force: :cascade do |t|
    t.bigint "guten_book_id"
    t.string "subject_id"
    t.index ["guten_book_id", "subject_id"], name: "index_guten_books_subjects_on_guten_book_id_and_subject_id", unique: true
    t.index ["guten_book_id"], name: "index_guten_books_subjects_on_guten_book_id"
    t.index ["subject_id"], name: "index_guten_books_subjects_on_subject_id"
  end

  create_table "senders", id: :serial, force: :cascade do |t|
    t.string "nickname", null: false
    t.string "name", null: false
    t.date "locked_until"
    t.datetime "created_at", precision: 6, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "now()" }, null: false
    t.index ["locked_until"], name: "index_senders_on_locked_until"
  end

  create_table "skip_histories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_skip_histories_on_user_id"
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
    t.string "activation_state"
    t.string "activation_token"
    t.datetime "activation_token_expires_at"
    t.string "sendgrid_id"
    t.datetime "trial_end_at"
    t.boolean "list_subscribed", default: false
    t.index ["activation_token"], name: "index_users_on_activation_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["magic_login_token"], name: "index_users_on_magic_login_token"
    t.index ["remember_me_token"], name: "index_users_on_remember_me_token"
    t.index ["sendgrid_id"], name: "index_users_on_sendgrid_id", unique: true
    t.index ["trial_end_at"], name: "index_users_on_trial_end_at"
  end

  add_foreign_key "campaign_groups", "aozora_books", column: "book_id"
  add_foreign_key "campaigns", "campaign_groups"
  add_foreign_key "charges", "users"
  add_foreign_key "guten_books_subjects", "subjects"
  add_foreign_key "skip_histories", "users"
end
