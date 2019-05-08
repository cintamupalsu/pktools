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

ActiveRecord::Schema.define(version: 2019_05_08_021734) do

  create_table "answer_denpyos", force: :cascade do |t|
    t.text "content"
    t.integer "watson_language_master_id"
    t.integer "answer_id"
    t.integer "hospital_id"
    t.integer "vendor_id"
    t.integer "user_id"
    t.integer "file_manager_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["answer_id", "created_at"], name: "index_answer_denpyos_on_answer_id_and_created_at"
    t.index ["answer_id"], name: "index_answer_denpyos_on_answer_id"
    t.index ["file_manager_id"], name: "index_answer_denpyos_on_file_manager_id"
    t.index ["hospital_id"], name: "index_answer_denpyos_on_hospital_id"
    t.index ["user_id"], name: "index_answer_denpyos_on_user_id"
    t.index ["vendor_id"], name: "index_answer_denpyos_on_vendor_id"
    t.index ["watson_language_master_id"], name: "index_answer_denpyos_on_watson_language_master_id"
  end

  create_table "answers", force: :cascade do |t|
    t.string "name"
    t.integer "question_id"
    t.integer "user_id"
    t.string "column"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id", "user_id"], name: "index_answers_on_question_id_and_user_id"
    t.index ["question_id"], name: "index_answers_on_question_id"
    t.index ["user_id"], name: "index_answers_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.text "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_companies_on_user_id_and_name"
    t.index ["user_id"], name: "index_companies_on_user_id"
  end

  create_table "dailyexcercises", force: :cascade do |t|
    t.datetime "daily"
    t.integer "kmondai_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kmondai_id"], name: "index_dailyexcercises_on_kmondai_id"
    t.index ["user_id"], name: "index_dailyexcercises_on_user_id"
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

  create_table "file_managers", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status"
    t.binary "data"
    t.string "comment"
    t.string "content_type"
    t.integer "ws_from"
    t.integer "ws_to"
    t.integer "hospital_id"
    t.integer "vendor_id"
    t.integer "question_id"
    t.integer "first_row"
    t.integer "question_col"
    t.string "answer_col"
    t.string "picture"
    t.index ["hospital_id"], name: "index_file_managers_on_hospital_id"
    t.index ["question_id"], name: "index_file_managers_on_question_id"
    t.index ["user_id"], name: "index_file_managers_on_user_id"
    t.index ["vendor_id"], name: "index_file_managers_on_vendor_id"
  end

  create_table "fkaitos", force: :cascade do |t|
    t.integer "fukusu_id"
    t.integer "user_id"
    t.integer "kmondai_id"
    t.integer "fmondai_id"
    t.integer "answer"
    t.boolean "kettei"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "correct"
    t.string "answerstring"
    t.index ["fmondai_id"], name: "index_fkaitos_on_fmondai_id"
    t.index ["fukusu_id"], name: "index_fkaitos_on_fukusu_id"
    t.index ["kmondai_id"], name: "index_fkaitos_on_kmondai_id"
    t.index ["user_id"], name: "index_fkaitos_on_user_id"
  end

  create_table "fmondais", force: :cascade do |t|
    t.integer "fukusu_id"
    t.integer "kmondai_id"
    t.boolean "kettei"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fukusu_id"], name: "index_fmondais_on_fukusu_id"
    t.index ["kmondai_id"], name: "index_fmondais_on_kmondai_id"
  end

  create_table "fukusus", force: :cascade do |t|
    t.integer "user_id"
    t.string "fname"
    t.integer "numofexam"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_fukusus_on_user_id"
  end

  create_table "fusers", force: :cascade do |t|
    t.integer "user_id"
    t.integer "fukusu_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "result"
    t.boolean "testdone"
    t.float "resultfloat"
    t.index ["fukusu_id"], name: "index_fusers_on_fukusu_id"
    t.index ["user_id"], name: "index_fusers_on_user_id"
  end

  create_table "gfiles", force: :cascade do |t|
    t.string "name"
    t.binary "data"
    t.string "picture"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hospitals", force: :cascade do |t|
    t.integer "company_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_hospitals_on_company_id"
    t.index ["user_id"], name: "index_hospitals_on_user_id"
  end

  create_table "kchoices", force: :cascade do |t|
    t.integer "kmondai_id"
    t.string "sentence"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "number"
    t.integer "answerno"
    t.index ["kmondai_id"], name: "index_kchoices_on_kmondai_id"
    t.index ["number"], name: "index_kchoices_on_number"
  end

  create_table "kenteikaitous", force: :cascade do |t|
    t.integer "user_id"
    t.datetime "datetest"
    t.string "answer"
    t.integer "kmondai_id"
    t.boolean "correct"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kmondai_id"], name: "index_kenteikaitous_on_kmondai_id"
    t.index ["user_id"], name: "index_kenteikaitous_on_user_id"
  end

  create_table "kmondais", force: :cascade do |t|
    t.integer "number"
    t.string "question"
    t.integer "level"
    t.string "answer"
    t.string "system"
    t.string "order"
    t.string "suborder"
    t.string "explanation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "oriquestion"
    t.boolean "demasu"
  end

  create_table "perform_denpyos", force: :cascade do |t|
    t.integer "user_id"
    t.integer "perform_detail_id"
    t.float "value"
    t.integer "minutes"
    t.float "completed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "performance_id"
    t.datetime "create_at_utc"
    t.datetime "created_at_utc"
    t.index ["perform_detail_id"], name: "index_perform_denpyos_on_perform_detail_id"
    t.index ["performance_id"], name: "index_perform_denpyos_on_performance_id"
    t.index ["user_id"], name: "index_perform_denpyos_on_user_id"
  end

  create_table "perform_details", force: :cascade do |t|
    t.integer "performance_id"
    t.integer "shorui"
    t.string "description"
    t.integer "points"
    t.datetime "dateset"
    t.float "maxvalue"
    t.float "minvalue"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "minminutestime"
    t.string "valuename"
    t.string "flinks"
    t.index ["performance_id"], name: "index_perform_details_on_performance_id"
  end

  create_table "performances", force: :cascade do |t|
    t.string "name"
    t.string "k_pic"
    t.integer "user_id"
    t.integer "u_user"
    t.string "description"
    t.integer "points"
    t.integer "shurui"
    t.integer "schedule"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_performances_on_user_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "name"
    t.string "column"
    t.integer "user_id"
    t.integer "mark"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_questions_on_user_id_and_name"
    t.index ["user_id"], name: "index_questions_on_user_id"
  end

  create_table "sentences", force: :cascade do |t|
    t.text "content"
    t.integer "file_manager_id"
    t.integer "question"
    t.integer "answer"
    t.integer "hospital"
    t.integer "vendor"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "watson_language_master_id"
    t.integer "wlu"
    t.index ["file_manager_id"], name: "index_sentences_on_file_manager_id"
    t.index ["user_id", "file_manager_id", "question"], name: "index_sentences_on_user_id_and_file_manager_id_and_question"
    t.index ["user_id"], name: "index_sentences_on_user_id"
    t.index ["watson_language_master_id"], name: "index_sentences_on_watson_language_master_id"
  end

  create_table "settings", force: :cascade do |t|
    t.integer "shorui"
    t.integer "user_id"
    t.integer "target"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_settings_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "marshal"
    t.boolean "activated"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vendors", force: :cascade do |t|
    t.integer "company_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_vendors_on_company_id"
    t.index ["user_id"], name: "index_vendors_on_user_id"
  end

  create_table "watson_language_keywords", force: :cascade do |t|
    t.integer "watson_language_master_id"
    t.string "keyword"
    t.float "relevance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["watson_language_master_id"], name: "index_watson_language_keywords_on_watson_language_master_id"
  end

  create_table "watson_language_masters", force: :cascade do |t|
    t.text "content"
    t.text "variant"
    t.integer "anchor"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "file_manager_id"
    t.index ["file_manager_id"], name: "index_watson_language_masters_on_file_manager_id"
    t.index ["user_id", "content"], name: "index_watson_language_masters_on_user_id_and_content"
    t.index ["user_id"], name: "index_watson_language_masters_on_user_id"
  end

end
