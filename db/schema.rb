# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20141213213351) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "health_inspections", force: true do |t|
    t.text     "boro"
    t.text     "building"
    t.text     "phone"
    t.text     "camis"
    t.text     "dba"
    t.text     "street"
    t.text     "zipcode"
    t.text     "inspection_type"
    t.datetime "grade_date"
    t.text     "score"
    t.text     "cuisine_description"
    t.text     "violation_description"
    t.datetime "inspection_date"
    t.text     "critical_flag"
    t.text     "violation_code"
    t.datetime "record_date"
    t.text     "action"
    t.text     "grade"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "seamless_vendor_id"
    t.float    "latitude"
    t.float    "longitude"
  end

  add_index "health_inspections", ["dba"], name: "index_health_inspections_on_dba", using: :btree
  add_index "health_inspections", ["grade"], name: "index_health_inspections_on_grade", using: :btree
  add_index "health_inspections", ["phone"], name: "index_health_inspections_on_phone", using: :btree
  add_index "health_inspections", ["seamless_vendor_id"], name: "index_health_inspections_on_seamless_vendor_id", using: :btree

  create_table "inspections", force: true do |t|
    t.integer  "restaurant_id",         null: false
    t.string   "inspection_type"
    t.text     "violation_description"
    t.datetime "grade_date"
    t.datetime "inspection_date"
    t.string   "critical_flag"
    t.string   "violation_code"
    t.datetime "record_date"
    t.text     "action"
    t.string   "grade"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "restaurants", force: true do |t|
    t.string   "name"
    t.string   "phone"
    t.string   "building"
    t.string   "street"
    t.string   "zip"
    t.string   "borough"
    t.string   "cuisine_description"
    t.string   "current_grade"
    t.string   "seamless_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "inspections", "restaurants", name: "inspections_restaurant_id_fk"

end
