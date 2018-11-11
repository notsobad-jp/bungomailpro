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

ActiveRecord::Schema.define(version: 2018_11_11_062338) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "books", id: false, force: :cascade do |t|
    t.bigint "id", null: false
    t.string "title", null: false
    t.string "author", null: false
    t.bigint "author_id", null: false
    t.text "text"
    t.text "footnote"
    t.index ["id"], name: "index_books_on_id", unique: true
  end

  create_table "course_books", force: :cascade do |t|
    t.bigint "course_id"
    t.bigint "book_id"
    t.integer "index", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_course_books_on_book_id"
    t.index ["course_id", "book_id"], name: "index_course_books_on_course_id_and_book_id", unique: true
    t.index ["course_id"], name: "index_course_books_on_course_id"
    t.index ["index"], name: "index_course_books_on_index"
  end

  create_table "courses", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.bigint "owner_id", null: false
    t.integer "status", default: 1, null: false, comment: "1:draft, 2:public, 3:closed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_courses_on_owner_id"
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
    t.bigint "user_course_id"
    t.bigint "book_id"
    t.integer "index", null: false
    t.text "text"
    t.datetime "deliver_at"
    t.boolean "delivered", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_deliveries_on_book_id"
    t.index ["deliver_at"], name: "index_deliveries_on_deliver_at"
    t.index ["delivered"], name: "index_deliveries_on_delivered"
    t.index ["user_course_id", "book_id", "index"], name: "index_deliveries_on_user_course_id_and_book_id_and_index", unique: true
    t.index ["user_course_id"], name: "index_deliveries_on_user_course_id"
  end

  create_table "user_courses", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "course_id"
    t.integer "next_book_index", default: 1, null: false
    t.integer "status", default: 1, null: false, comment: "1:active, 2:paused, 3:finished"
    t.text "delivery_hours"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_user_courses_on_course_id"
    t.index ["status"], name: "index_user_courses_on_status"
    t.index ["user_id", "course_id"], name: "index_user_courses_on_user_id_and_course_id", unique: true
    t.index ["user_id"], name: "index_user_courses_on_user_id"
  end

  create_table "users", force: :cascade do |t|
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
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["magic_login_token"], name: "index_users_on_magic_login_token"
    t.index ["remember_me_token"], name: "index_users_on_remember_me_token"
  end

  add_foreign_key "course_books", "books"
  add_foreign_key "course_books", "courses"
  add_foreign_key "deliveries", "books"
  add_foreign_key "deliveries", "user_courses"
  add_foreign_key "user_courses", "courses"
  add_foreign_key "user_courses", "users"
end
