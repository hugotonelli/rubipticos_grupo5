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

ActiveRecord::Schema[8.1].define(version: 2026_11_28_140843) do
  create_table "configuraciones", force: :cascade do |t|
    t.string "url_fuente", null: false
    t.text "texto_bienvenida", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cripticos", force: :cascade do |t|
    t.string "id_fuente", null: false
    t.text "enunciado", null: false
    t.string "enumeracion", null: false
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
    t.string "origen", default: "catedra", null: false
    t.boolean "desactivado_por_sincronizacion", default: false, null: false
    t.index ["activo"], name: "index_cripticos_on_activo"
    t.index ["dificultad_id"], name: "index_cripticos_on_dificultad_id"
    t.index ["id_fuente"], name: "index_cripticos_on_id_fuente", unique: true
    t.index ["origen"], name: "index_cripticos_on_origen"
    t.index ["tipo_id"], name: "index_cripticos_on_tipo_id"
    t.check_constraint "enumeracion GLOB '(*)'", name: "cripticos_enumeracion_entre_parentesis"
    t.check_constraint "origen IN ('catedra', 'propio')", name: "cripticos_origen_valido"
  end

  create_table "dificultades", force: :cascade do |t|
    t.string "nombre", null: false
    t.decimal "multiplicador", precision: 3, scale: 2, default: "1.0", null: false
    t.integer "tiempo", default: 60, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nombre"], name: "index_dificultades_on_nombre", unique: true
    t.check_constraint "multiplicador > 0 AND multiplicador <= 5", name: "dificultades_multiplicador_en_rango"
    t.check_constraint "nombre IN ('facil', 'medio', 'avanzado')", name: "dificultades_nombre_valido"
    t.check_constraint "tiempo > 0", name: "dificultades_tiempo_positivo"
  end

  create_table "jugadores", force: :cascade do |t|
    t.string "nombre", null: false
    t.string "token", null: false
    t.boolean "bloqueado", default: false, null: false
    t.integer "racha_actual", default: 0, null: false
    t.integer "mejor_racha", default: 0, null: false
    t.date "ultimo_dia_jugado"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower(nombre)", name: "index_jugadores_on_lower_nombre", unique: true
    t.index ["token"], name: "index_jugadores_on_token", unique: true
    t.check_constraint "length(nombre) BETWEEN 3 AND 20", name: "jugadores_nombre_largo"
    t.check_constraint "racha_actual >= 0 AND mejor_racha >= racha_actual", name: "jugadores_rachas_validas"
  end

  create_table "partidas", force: :cascade do |t|
    t.integer "jugador_id", null: false
    t.integer "criptico_id", null: false
    t.integer "estado", default: 0, null: false
    t.datetime "iniciada_at", null: false
    t.datetime "finalizada_at"
    t.integer "intentos", default: 0, null: false
    t.integer "pistas_usadas", default: 0, null: false
    t.integer "puntos", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["criptico_id"], name: "index_partidas_on_criptico_id"
    t.index ["estado", "finalizada_at"], name: "index_partidas_on_estado_and_finalizada_at"
    t.index ["jugador_id", "criptico_id"], name: "index_partidas_on_jugador_id_and_criptico_id", unique: true
    t.index ["jugador_id"], name: "index_partidas_on_jugador_id"
    t.index ["jugador_id"], name: "index_partidas_una_en_curso_por_jugador", unique: true, where: "estado = 0"
    t.check_constraint "estado = 0 OR finalizada_at IS NOT NULL", name: "partidas_finalizada_tiene_fecha"
    t.check_constraint "estado IN (0, 1, 2)", name: "partidas_estado_valido"
    t.check_constraint "intentos BETWEEN 0 AND 5", name: "partidas_intentos_en_rango"
    t.check_constraint "pistas_usadas BETWEEN 0 AND 4", name: "partidas_pistas_en_rango"
    t.check_constraint "puntos >= 0", name: "partidas_puntos_no_negativos"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "sincronizaciones", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "url", null: false
    t.string "version"
    t.integer "estado", null: false
    t.text "mensaje"
    t.integer "creados", default: 0, null: false
    t.integer "actualizados", default: 0, null: false
    t.integer "desactivados", default: 0, null: false
    t.integer "rechazados", default: 0, null: false
    t.json "detalle_rechazados", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["estado", "created_at"], name: "index_sincronizaciones_on_estado_and_created_at"
    t.index ["user_id"], name: "index_sincronizaciones_on_user_id"
    t.check_constraint "creados >= 0 AND actualizados >= 0 AND desactivados >= 0 AND rechazados >= 0", name: "sincronizaciones_cantidades_no_negativas"
    t.check_constraint "estado = 2 OR version IS NOT NULL", name: "sincronizaciones_version_si_no_fallo"
    t.check_constraint "estado IN (0, 1, 2)", name: "sincronizaciones_estado_valido"
  end

  create_table "tipos", force: :cascade do |t|
    t.string "nombre", null: false
    t.integer "puntos", default: 100, null: false
    t.text "descripcion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nombre"], name: "index_tipos_on_nombre", unique: true
    t.check_constraint "nombre IN ('anagrama', 'oculta', 'charada', 'contenedor', 'inversion', 'supresion', 'homofono', 'doble_definicion', 'iniciales', 'finales', 'sustitucion', 'simbolos', 'combinada')", name: "tipos_nombre_valido"
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
  add_foreign_key "partidas", "cripticos"
  add_foreign_key "partidas", "jugadores"
  add_foreign_key "sessions", "users"
  add_foreign_key "sincronizaciones", "users"
end
