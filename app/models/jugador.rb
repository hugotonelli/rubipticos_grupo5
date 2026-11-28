# Jugador del sitio público. Lo identifica un token (guardado en una cookie firmada), no el nombre:
# por eso puede cambiar de nombre sin perder su historial, su racha ni sus puntos.
class Jugador < ApplicationRecord
  has_secure_token :token
  has_many :partidas, dependent: :restrict_with_error

  normalizes :nombre, with: ->(nombre) { nombre.strip }

  # Entre 3 y 20 caracteres, único sin distinguir mayúsculas, sin espacios al principio ni al final
  # (los saca `normalizes`).
  validates :nombre, presence: true, length: { in: 3..20 }, uniqueness: { case_sensitive: false }

  # Los bloqueados no aparecen en la tabla de posiciones.
  scope :visibles, -> { where(bloqueado: false) }

  # La partida que dejó abierta (si cerró la pestaña, al volver la retoma).
  def partida_en_curso
    partidas.en_curso.first
  end

  # Racha que cuenta hoy: si el último día jugado fue antes de ayer, la racha se cortó.
  def racha_vigente(hoy = Date.current)
    return 0 if ultimo_dia_jugado.nil? || ultimo_dia_jugado < hoy - 1

    racha_actual
  end
end
