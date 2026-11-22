# Registro de cada sincronización del catálogo: cuándo (created_at), quién, qué versión y cómo resultó.
class CreateSincronizaciones < ActiveRecord::Migration[8.1]
  def change
    create_table :sincronizaciones do |t|
      t.references :user, null: false, foreign_key: true
      t.string :url, null: false
      # Versión del catálogo (nula si falló antes de poder leerla).
      t.string :version
      # 0 = exitosa, 1 = sin_cambios, 2 = fallida (ver Sincronizacion).
      t.integer :estado, null: false
      # Motivo del error cuando falla (red, JSON inválido, ...).
      t.text :mensaje
      t.integer :creados, null: false, default: 0
      t.integer :actualizados, null: false, default: 0
      t.integer :desactivados, null: false, default: 0
      t.integer :rechazados, null: false, default: 0
      # Lista de { "id" => ..., "motivo" => ... } de los crípticos rechazados.
      t.json :detalle_rechazados, null: false, default: []

      t.timestamps
    end
    add_index :sincronizaciones, [ :estado, :created_at ]
    add_check_constraint :sincronizaciones, "estado IN (0, 1, 2)", name: "sincronizaciones_estado_valido"
    add_check_constraint :sincronizaciones,
                         "creados >= 0 AND actualizados >= 0 AND desactivados >= 0 AND rechazados >= 0",
                         name: "sincronizaciones_cantidades_no_negativas"
  end
end
