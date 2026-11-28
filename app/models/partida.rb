# Una partida de un jugador con un críptico. El tiempo oficial lo miden los timestamps del servidor.
class Partida < ApplicationRecord
  MAXIMO_INTENTOS = 5
  MAXIMO_PISTAS = 4

  belongs_to :jugador
  belongs_to :criptico

  enum :estado, { en_curso: 0, resuelta: 1, rendida: 2 }, validate: true

  validates :iniciada_at, presence: true
  validates :finalizada_at, presence: true, unless: :en_curso?
  # Cada críptico se juega una sola vez por jugador.
  validates :criptico_id, uniqueness: { scope: :jugador_id, message: "ya fue jugado por este jugador" }
  # Como máximo una partida en curso por jugador (al volver, retoma esa).
  validates :jugador_id, uniqueness: { conditions: -> { en_curso }, message: "ya tiene una partida en curso" },
                         if: :en_curso?
  validates :intentos, numericality: { only_integer: true, in: 0..MAXIMO_INTENTOS }
  validates :pistas_usadas, numericality: { only_integer: true, in: 0..MAXIMO_PISTAS }
  validates :puntos, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :finalizadas, -> { where.not(estado: :en_curso) }

  SIN_ESTADISTICAS = { jugadas: 0, porcentaje_resuelto: nil, tiempo_promedio: nil }.freeze

  # Estadísticas por críptico, con una consulta agrupada por dato (no una por críptico):
  #   { criptico_id => { jugadas:, porcentaje_resuelto:, tiempo_promedio: } }
  # - jugadas: todas las partidas (también las que siguen en curso).
  # - porcentaje_resuelto: resueltas sobre terminadas (resueltas + rendidas); nil si ninguna terminó.
  # - tiempo_promedio: segundos promedio de las resueltas; nil si no hay.
  def self.estadisticas_por_criptico(criptico_ids)
    partidas = where(criptico_id: criptico_ids).group(:criptico_id)
    jugadas = partidas.count
    resueltas = partidas.resuelta.count
    terminadas = partidas.finalizadas.count
    # julianday es la función de fechas de SQLite: la diferencia viene en días, × 86400 = segundos.
    promedios = partidas.resuelta.average(Arel.sql("(julianday(finalizada_at) - julianday(iniciada_at)) * 86400"))

    jugadas.to_h do |criptico_id, cantidad|
      total_terminadas = terminadas.fetch(criptico_id, 0)
      [ criptico_id, {
        jugadas: cantidad,
        porcentaje_resuelto: total_terminadas.positive? ? (resueltas.fetch(criptico_id, 0) * 100.0 / total_terminadas).round : nil,
        tiempo_promedio: promedios[criptico_id]&.round
      } ]
    end
  end

  # Segundos que tardó, calculados con los timestamps del servidor (nil si sigue en curso).
  def segundos
    return if finalizada_at.nil?

    (finalizada_at - iniciada_at).round
  end
end
