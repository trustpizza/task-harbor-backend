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

ActiveRecord::Schema[7.1].define(version: 2025_02_11_180826) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "project_field_definitions", force: :cascade do |t|
    t.string "name"
    t.string "field_type"
    t.text "options"
    t.bigint "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_field_definitions_on_project_id"
  end

  create_table "project_field_values", force: :cascade do |t|
    t.text "value"
    t.bigint "project_id", null: false
    t.bigint "project_field_definition_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_field_definition_id"], name: "index_project_field_values_on_project_field_definition_id"
    t.index ["project_id"], name: "index_project_field_values_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.date "due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "project_field_definitions", "projects"
  add_foreign_key "project_field_values", "project_field_definitions"
  add_foreign_key "project_field_values", "projects"
end
