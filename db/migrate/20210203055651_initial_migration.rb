class InitialMigration < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

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
      t.datetime "created_at", null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime "updated_at", null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.uuid "campaign_group_id", null: false
      t.index ["campaign_group_id"], name: "index_campaigns_on_campaign_group_id"
      t.index ["sendgrid_id"], name: "index_campaigns_on_sendgrid_id", unique: true
    end

    create_table "delayed_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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

    create_table "subjects", id: :string, force: :cascade do |t|
      t.integer "books_count", default: 0
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    add_foreign_key "campaign_groups", "aozora_books", column: "book_id"
    add_foreign_key "campaigns", "campaign_groups"
    add_foreign_key "guten_books_subjects", "subjects"
  end
end
