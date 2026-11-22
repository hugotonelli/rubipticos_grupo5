# Configuración general del juego. Hay una sola fila: se usa siempre Configuracion.actual.
class Configuracion < ApplicationRecord
  URL_CATEDRA = "https://ecorrons.github.io/cryptics-api/v1/cryptics.json".freeze
  TEXTO_BIENVENIDA_INICIAL = "¡Bienvenido a Rubípticos! Elegí una dificultad y resolvé crípticos para sumar puntos.".freeze

  validates :url_fuente, presence: true, format: { with: URI::RFC2396_PARSER.make_regexp(%w[http https]), message: "debe ser una URL http o https" }
  validates :texto_bienvenida, length: { maximum: 1000 }

  def self.actual
    first || create!(url_fuente: URL_CATEDRA, texto_bienvenida: TEXTO_BIENVENIDA_INICIAL)
  end
end
