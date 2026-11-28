# Jugador del sitio público. Lo identifica un token (guardado en una cookie firmada), no el nombre:
# por eso puede cambiar de nombre sin perder su historial, su racha ni sus puntos.
class Jugador < ApplicationRecord
  has_secure_token :token
  has_many :partidas, dependent: :restrict_with_error

  normalizes :nombre, with: ->(nombre) { nombre.strip }

  # El nombre en minúsculas (calculado en Ruby, que entiende Ñ y tildes): es lo que tiene que ser
  # único, así «Ñandú» y «ñandú» cuentan como el mismo nombre. En la base tiene un índice único.
  before_validation { self.nombre_clave = nombre.to_s.downcase }

  # Entre 3 y 20 caracteres, sin espacios al principio ni al final (los saca `normalizes`)
  # y único sin distinguir mayúsculas.
  validates :nombre, presence: true, length: { in: 3..20 }
  validate :nombre_disponible

  # Los bloqueados no aparecen en la tabla de posiciones.
  scope :visibles, -> { where(bloqueado: false) }

  # ¿Hay otro jugador con este nombre (sin distinguir mayúsculas)?
  def self.nombre_tomado?(nombre)
    exists?(nombre_clave: nombre.to_s.strip.downcase)
  end

  # Como save, pero si otro pedido guardó el mismo nombre al mismo tiempo (y la base lo rechaza
  # por el índice único), lo informa como un error de validación en lugar de romper.
  def guardar
    save
  rescue ActiveRecord::RecordNotUnique
    errors.add(:nombre, :taken)
    false
  end

  # La partida que dejó abierta (si cerró la pestaña, al volver la retoma).
  def partida_en_curso
    partidas.en_curso.first
  end

  # Racha que cuenta hoy: si el último día jugado fue antes de ayer, la racha se cortó.
  def racha_vigente(hoy = Date.current)
    return 0 if ultimo_dia_jugado.nil? || ultimo_dia_jugado < hoy - 1

    racha_actual
  end

  private

  def nombre_disponible
    otros = Jugador.where(nombre_clave: nombre_clave)
    otros = otros.where.not(id: id) if persisted?
    errors.add(:nombre, :taken) if nombre_clave.present? && otros.exists?
  end
end
