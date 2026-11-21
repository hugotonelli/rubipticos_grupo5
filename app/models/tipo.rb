class Tipo < ApplicationRecord
  validates :tipo, presence: true
  validates :puntos, comparison: { greater_than_or_equal_to: 10, less_than_or_equal_to: 1000 }
end
