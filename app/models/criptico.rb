class Criptico < ApplicationRecord
  # Tipo y dificultad son tablas propias porque sus puntos y multiplicadores se editan desde el backend.
  belongs_to :tipo
  belongs_to :dificultad
  # No se borran crípticos jugados: se desactivan.
  has_many :partidas, dependent: :restrict_with_error

  scope :activos, -> { where(activo: true) }

  # `enunciado`, `respuesta`, `tipo` y `dificultad` son obligatorios.
  validates :enunciado, :respuesta, :tipo, :dificultad, presence: true
  # Identificador del críptico en la API de la cátedra: estable y nunca se reutiliza.
  validates :id_fuente, presence: true, uniqueness: true

  # `tipo` y `dificultad` pertenecen a los valores definidos: lo garantizan las claves foráneas
  # y la validación `inclusion` de Tipo y Dificultad.

  # La enumeración coincide con el largo de la respuesta, sin contar tildes ni espacios.
  validates :enumeracion, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :coincide_enumeracion_y_largo_respuesta, if: -> { enumeracion.present? && respuesta.present? }

  # TODO: Cada definición, indicador y material aparece textualmente en el enunciado.

  # TODO: La doble definición lleva 2 definiciones

  # TODO: Si el tipo es oculta, la respuesta está dentro del material, sin espacios. Si es anagrama, el material tiene exactamente las mismas letras que la respuesta. Si es iniciales o finales, las primeras o últimas letras del material forman la respuesta.
  #       Ojo con iniciales/finales: hay que ignorar palabras de unión. En cr-021 el material es
  #       "álbum, casa y amor" y la respuesta MAR (álbuM, casA, amoR): si se cuenta la "y" da MAYR.

  # A partir de acá comienzan los métodos privados
  private

  def coincide_enumeracion_y_largo_respuesta
    if enumeracion != NormalizadorDeTexto.call(respuesta).length
      errors.add(:enumeracion, "debe coincidir con el largo de la respuesta")
    end
  end
end
