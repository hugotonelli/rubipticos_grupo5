class Tipo < ApplicationRecord
  has_many :cripticos, dependent: :restrict_with_error

  validates :tipo, presence: true, uniqueness: true
  # Los puntos de un tipo son un número entero entre 10 y 1000.
  validates :puntos, numericality: { only_integer: true, greater_than_or_equal_to: 10, less_than_or_equal_to: 1000 }
end
