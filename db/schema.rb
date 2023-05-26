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

ActiveRecord::Schema.define(version: 2023_05_24_101655) do

  create_table "messages", force: :cascade do |t|
    t.text "content", null: false
    t.integer "room_id", null: false
    t.integer "user_id", null: false
    t.index ["room_id"], name: "index_messages_on_room_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "otps", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "code"
    t.datetime "expiration_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_otps_on_code"
    t.index ["user_id"], name: "index_otps_on_user_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.integer "user1_id", null: false
    t.integer "user2_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user1_id"], name: "index_rooms_on_user1_id"
    t.index ["user2_id"], name: "index_rooms_on_user2_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "phone"
    t.string "username"
    t.string "status"
    t.boolean "verified"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "messages", "rooms"
  add_foreign_key "messages", "users"
  add_foreign_key "otps", "users"
  add_foreign_key "rooms", "users", column: "user1_id"
  add_foreign_key "rooms", "users", column: "user2_id"
end
