# Un jugador tiene como máximo una partida en curso: si cierra la pestaña, al volver retoma esa misma
# (enunciado, «Partida»). Índice único parcial: solo cuenta las filas con estado = 0 (en_curso).
class AgregaUnaPartidaEnCursoPorJugador < ActiveRecord::Migration[8.1]
  def change
    add_index :partidas, :jugador_id, unique: true, where: "estado = 0", name: "index_partidas_una_en_curso_por_jugador"
  end
end
