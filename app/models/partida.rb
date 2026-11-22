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
  validates :intentos, numericality: { only_integer: true, in: 0..MAXIMO_INTENTOS }
  validates :pistas_usadas, numericality: { only_integer: true, in: 0..MAXIMO_PISTAS }
  validates :puntos, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :finalizadas, -> { where.not(estado: :en_curso) }

  # Segundos que tardó, calculados con los timestamps del servidor (nil si sigue en curso).
  def segundos
    return if finalizada_at.nil?

    (finalizada_at - iniciada_at).round
  end
end
