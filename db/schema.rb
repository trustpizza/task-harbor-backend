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

ActiveRecord::Schema[7.1].define(version: 2025_02_13_175309) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "field_definitions", force: :cascade do |t|
    t.string "name"
    t.string "field_type"
    t.text "options"
    t.boolean "required", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "field_values", force: :cascade do |t|
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "field_id", null: false
    t.index ["field_id"], name: "index_field_values_on_field_id"
  end

  create_table "fields", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "field_definition_id", null: false
    t.index ["field_definition_id"], name: "index_fields_on_field_definition_id"
    t.index ["project_id"], name: "index_fields_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.date "due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "field_values", "fields"
  add_foreign_key "fields", "field_definitions"
  add_foreign_key "fields", "projects"
end
