# Cada vez que un jugador juega un críptico. Un jugador juega cada críptico una sola vez.
class CreatePartidas < ActiveRecord::Migration[8.1]
  def change
    create_table :partidas do |t|
      t.references :jugador, null: false, foreign_key: true
      t.references :criptico, null: false, foreign_key: true
      # 0 = en_curso, 1 = resuelta, 2 = rendida (ver Partida).
      t.integer :estado, null: false, default: 0
      # Timestamps oficiales del servidor: el tiempo de la partida es finalizada_at - iniciada_at.
      t.datetime :iniciada_at, null: false
      t.datetime :finalizada_at
      t.integer :intentos, null: false, default: 0
      t.integer :pistas_usadas, null: false, default: 0
      # Se calculan y se guardan al resolver: cambiar la configuración no recalcula partidas viejas.
      t.integer :puntos, null: false, default: 0

      t.timestamps
    end
    add_index :partidas, [ :jugador_id, :criptico_id ], unique: true
    add_index :partidas, [ :estado, :finalizada_at ]
    add_check_constraint :partidas, "estado IN (0, 1, 2)", name: "partidas_estado_valido"
    add_check_constraint :partidas, "intentos BETWEEN 0 AND 5", name: "partidas_intentos_en_rango"
    add_check_constraint :partidas, "pistas_usadas BETWEEN 0 AND 4", name: "partidas_pistas_en_rango"
    add_check_constraint :partidas, "puntos >= 0", name: "partidas_puntos_no_negativos"
    add_check_constraint :partidas, "estado = 0 OR finalizada_at IS NOT NULL", name: "partidas_finalizada_tiene_fecha"
  end
end
