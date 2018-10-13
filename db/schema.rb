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

ActiveRecord::Schema.define(version: 2018_10_07_160651) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "books", force: :cascade do |t|
    t.integer "aozora_id", null: false
    t.string "title"
    t.string "author"
    t.index ["aozora_id"], name: "index_books_on_aozora_id", unique: true
  end

  create_table "chapters", force: :cascade do |t|
    t.bigint "book_id"
    t.integer "index"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_chapters_on_book_id"
    t.index ["index"], name: "index_chapters_on_index"
  end

  create_table "course_books", force: :cascade do |t|
    t.bigint "course_id"
    t.bigint "book_id"
    t.integer "index"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_course_books_on_book_id"
    t.index ["course_id"], name: "index_course_books_on_course_id"
    t.index ["index"], name: "index_course_books_on_index"
  end

  create_table "courses", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "deliveries", force: :cascade do |t|
    t.bigint "user_course_id"
    t.bigint "chapter_id"
    t.datetime "deliver_at"
    t.boolean "delivered", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chapter_id"], name: "index_deliveries_on_chapter_id"
    t.index ["deliver_at"], name: "index_deliveries_on_deliver_at"
    t.index ["delivered"], name: "index_deliveries_on_delivered"
    t.index ["user_course_id"], name: "index_deliveries_on_user_course_id"
  end

  create_table "user_courses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_id", null: false
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
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["magic_login_token"], name: "index_users_on_magic_login_token"
  end

  add_foreign_key "chapters", "books"
  add_foreign_key "course_books", "books"
  add_foreign_key "course_books", "courses"
  add_foreign_key "deliveries", "chapters"
  add_foreign_key "deliveries", "user_courses"
  add_foreign_key "user_courses", "courses"
  add_foreign_key "user_courses", "users"
end
