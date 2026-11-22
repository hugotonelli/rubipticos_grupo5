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

ActiveRecord::Schema[8.1].define(version: 2026_11_22_001604) do
  create_table "cripticos", force: :cascade do |t|
    t.string "id_fuente", null: false
    t.text "enunciado", null: false
    t.integer "enumeracion"
    t.string "respuesta", null: false
    t.json "definiciones", default: [], null: false
    t.json "indicadores", default: [], null: false
    t.json "materiales", default: [], null: false
    t.text "ayuda"
    t.text "explicacion"
    t.string "autor"
    t.boolean "activo", default: true, null: false
    t.integer "tipo_id", null: false
    t.integer "dificultad_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activo"], name: "index_cripticos_on_activo"
    t.index ["dificultad_id"], name: "index_cripticos_on_dificultad_id"
    t.index ["id_fuente"], name: "index_cripticos_on_id_fuente", unique: true
    t.index ["tipo_id"], name: "index_cripticos_on_tipo_id"
  end

  create_table "dificultades", force: :cascade do |t|
    t.string "dificultad", null: false
    t.decimal "multiplicador", precision: 3, scale: 2, default: "1.0", null: false
    t.integer "tiempo", default: 60, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dificultad"], name: "index_dificultades_on_dificultad", unique: true
    t.check_constraint "multiplicador > 0 AND multiplicador <= 5", name: "dificultades_multiplicador_en_rango"
    t.check_constraint "tiempo > 0", name: "dificultades_tiempo_positivo"
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
    t.integer "puntos", default: 100, null: false
    t.text "descripcion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tipo"], name: "index_tipos_on_tipo", unique: true
    t.check_constraint "puntos BETWEEN 10 AND 1000", name: "tipos_puntos_en_rango"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rol", default: 0, null: false
    t.boolean "activo", default: true, null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.check_constraint "rol IN (0, 1)", name: "users_rol_valido"
  end

  add_foreign_key "cripticos", "dificultades"
  add_foreign_key "cripticos", "tipos"
  add_foreign_key "sessions", "users"
end
