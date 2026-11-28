# El nombre del jugador es único sin distinguir mayúsculas. El índice sobre lower(nombre) no
# alcanzaba: el lower() de SQLite solo convierte letras ASCII, así que «Ñandú» y «ñandú» quedaban
# como distintos. Ahora se guarda la clave en minúsculas calculada en Ruby (que sí entiende Ñ y
# tildes) y el índice único va sobre esa columna.
class AgregaNombreClaveAJugadores < ActiveRecord::Migration[8.1]
  # Modelo propio de la migración, para no depender de cómo esté el modelo Jugador en el futuro.
  class JugadorDeMigracion < ActiveRecord::Base
    self.table_name = "jugadores"
  end

  def up
    add_column :jugadores, :nombre_clave, :string
    JugadorDeMigracion.reset_column_information
    JugadorDeMigracion.find_each { |jugador| jugador.update_columns(nombre_clave: jugador.nombre.downcase) }
    change_column_null :jugadores, :nombre_clave, false

    remove_index :jugadores, name: "index_jugadores_on_lower_nombre"
    add_index :jugadores, :nombre_clave, unique: true
  end

  def down
    remove_index :jugadores, :nombre_clave
    add_index :jugadores, "lower(nombre)", unique: true, name: "index_jugadores_on_lower_nombre"
    remove_column :jugadores, :nombre_clave
  end
end
