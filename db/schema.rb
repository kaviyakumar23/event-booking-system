# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_03_15_034558) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookings", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.bigint "event_id", null: false
    t.bigint "ticket_id", null: false
    t.integer "quantity", null: false
    t.decimal "total_amount", precision: 10, scale: 2, null: false
    t.datetime "booking_date", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_bookings_on_customer_id"
    t.index ["event_id"], name: "index_bookings_on_event_id"
    t.index ["ticket_id"], name: "index_bookings_on_ticket_id"
  end

  create_table "customers", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_customers_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "organizer_id"
    t.string "title"
    t.text "description"
    t.datetime "event_date"
    t.string "venue"
    t.string "venue_address"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organizer_id"], name: "index_events_on_organizer_id"
  end

  create_table "organizers", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.string "phone"
    t.string "company_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_organizers_on_user_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "ticket_type", null: false
    t.integer "price", null: false
    t.integer "quantity", null: false
    t.integer "remaining", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_tickets_on_event_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest"
    t.string "role"
    t.datetime "last_signin_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "bookings", "customers"
  add_foreign_key "bookings", "events"
  add_foreign_key "bookings", "tickets"
  add_foreign_key "customers", "users"
  add_foreign_key "events", "users", column: "organizer_id"
  add_foreign_key "organizers", "users"
  add_foreign_key "tickets", "events"
end
