class Dificultad < ApplicationRecord
  validates :dificultad, :tiempo, presence: true
  validates :multiplicador, comparison: { greater_than: 0, less_than_or_equal_to: 5 }
end
