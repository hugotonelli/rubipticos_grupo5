# Jugadores del sitio público. No tienen cuenta: se identifican con un token guardado en una cookie firmada.
class CreateJugadores < ActiveRecord::Migration[8.1]
  def change
    create_table :jugadores do |t|
      t.string :nombre, null: false
      t.string :token, null: false
      # Los bloqueados (nombres ofensivos) no aparecen en la tabla de posiciones.
      t.boolean :bloqueado, null: false, default: false
      # Racha de días seguidos jugados, contando el último día jugado.
      t.integer :racha_actual, null: false, default: 0
      t.integer :mejor_racha, null: false, default: 0
      t.date :ultimo_dia_jugado

      t.timestamps
    end
    add_index :jugadores, :token, unique: true
    # Nombre único sin distinguir mayúsculas.
    add_index :jugadores, "lower(nombre)", unique: true, name: "index_jugadores_on_lower_nombre"
    add_check_constraint :jugadores, "length(nombre) BETWEEN 3 AND 20", name: "jugadores_nombre_largo"
    add_check_constraint :jugadores, "racha_actual >= 0 AND mejor_racha >= racha_actual", name: "jugadores_rachas_validas"
  end
end
