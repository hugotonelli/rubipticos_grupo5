# Registro de una sincronización del catálogo de crípticos (la hace SincronizadorDeCripticos).
class Sincronizacion < ApplicationRecord
  # El admin que la pidió.
  belongs_to :user

  enum :estado, { exitosa: 0, sin_cambios: 1, fallida: 2 }, validate: true

  validates :url, presence: true
  validates :version, presence: true, unless: :fallida?
  validates :mensaje, presence: true, if: :fallida?
  validates :creados, :actualizados, :desactivados, :rechazados,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :recientes, -> { order(created_at: :desc) }

  # Versión de la última sincronización que procesó el catálogo, para saber si hay cambios.
  def self.ultima_version_exitosa
    exitosa.order(:created_at, :id).last&.version
  end

  # Texto corto para el informe: «Sin cambios», el motivo del error o las cantidades.
  def resumen
    if sin_cambios?
      "Sin cambios"
    elsif fallida?
      "Falló: #{mensaje}"
    else
      "#{creados} creados, #{actualizados} actualizados, #{desactivados} desactivados, #{rechazados} rechazados"
    end
  end
end
