class Dificultad < ApplicationRecord
  has_many :cripticos, dependent: :restrict_with_error

  validates :dificultad, presence: true, uniqueness: true
  # El multiplicador es un número mayor que 0 y menor o igual a 5 (puede ser decimal, por ejemplo 1,5).
  validates :multiplicador, numericality: { greater_than: 0, less_than_or_equal_to: 5 }
  # Tiempo de referencia en segundos para el factor de tiempo del puntaje.
  validates :tiempo, numericality: { only_integer: true, greater_than: 0 }
end
