# Usuario del backend de administración (los jugadores no son usuarios: se identifican con un token).
class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :sincronizaciones, dependent: :restrict_with_error

  # editor_puntajes: solo ve y edita los puntos por tipo y los multiplicadores.
  # administrador: puede hacer todo en el backend.
  enum :rol, { editor_puntajes: 0, administrador: 1 }, validate: true

  scope :activos, -> { where(activo: true) }

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true
end
