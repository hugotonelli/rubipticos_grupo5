# Dificultad de un críptico. Su multiplicador y su tiempo de referencia se usan en el puntaje.
class Dificultad < ApplicationRecord
  # Identificador de la API => nombre para mostrar.
  NOMBRES = {
    "facil" => "Fácil",
    "medio" => "Medio",
    "avanzado" => "Avanzado"
  }.freeze

  has_many :cripticos, dependent: :restrict_with_error

  validates :nombre, presence: true, uniqueness: true, inclusion: { in: NOMBRES.keys }
  # El multiplicador es un número mayor que 0 y menor o igual a 5 (puede ser decimal, por ejemplo 1,5).
  validates :multiplicador, numericality: { greater_than: 0, less_than_or_equal_to: 5 }
  # Tiempo de referencia en segundos para el factor de tiempo del puntaje.
  validates :tiempo, numericality: { only_integer: true, greater_than: 0 }

  def to_s
    NOMBRES.fetch(nombre, nombre)
  end
end
