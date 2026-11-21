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

ActiveRecord::Schema[8.1].define(version: 2026_11_11_072827) do
  create_table "cripticos", id: :string, force: :cascade do |t|
    t.string "version"
    t.text "enunciado", null: false
    t.integer "enumeracion"
    t.string "respuesta", null: false
    t.text "ayuda"
    t.text "explicacion"
    t.string "autor"
    t.json "definiciones"
    t.json "indicadores"
    t.json "materiales"
    t.integer "tipo_id", null: false
    t.integer "dificultad_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dificultad_id"], name: "index_cripticos_on_dificultad_id"
    t.index ["tipo_id"], name: "index_cripticos_on_tipo_id"
  end

  create_table "dificultades", force: :cascade do |t|
    t.string "dificultad", null: false
    t.integer "multiplicador", default: 1, null: false
    t.integer "tiempo", default: 60, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tipos", force: :cascade do |t|
    t.string "tipo", null: false
    t.integer "puntos", default: 1, null: false
    t.text "descripcion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "cripticos", "dificultades"
  add_foreign_key "cripticos", "tipos"
  add_foreign_key "sessions", "users"
end
