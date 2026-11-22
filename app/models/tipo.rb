# Tipo de juego de palabras de un críptico. Sus puntos base se editan desde el backend.
class Tipo < ApplicationRecord
  # Los tipos que tiene que reconocer el sistema: identificador de la API => nombre para mostrar.
  NOMBRES = {
    "anagrama" => "Anagrama",
    "oculta" => "Oculta",
    "charada" => "Charada",
    "contenedor" => "Contenedor",
    "inversion" => "Inversión",
    "supresion" => "Supresión",
    "homofono" => "Homófono",
    "doble_definicion" => "Doble definición",
    "iniciales" => "Iniciales",
    "finales" => "Finales",
    "sustitucion" => "Sustitución",
    "simbolos" => "Símbolos",
    "combinada" => "Combinada"
  }.freeze

  has_many :cripticos, dependent: :restrict_with_error

  validates :nombre, presence: true, uniqueness: true, inclusion: { in: NOMBRES.keys }
  # Los puntos de un tipo son un número entero entre 10 y 1000.
  validates :puntos, numericality: { only_integer: true, greater_than_or_equal_to: 10, less_than_or_equal_to: 1000 }

  # Nombre para mostrar en pantalla (por ejemplo, en la primera pista: «Doble definición»).
  def to_s
    NOMBRES.fetch(nombre, nombre)
  end
end
