class Criptico < ApplicationRecord
  # TODO: Pensar si realmente conviene usar relaciones, o directamente el string normalizado para tipo y dificultad
  belongs_to :tipo
  belongs_to :dificultad

  # `enunciado`, `respuesta`, `tipo` y `dificultad` son obligatorios.
  validates :enunciado, :respuesta, :tipo, :dificultad, presence: true

  # TODO: `tipo` y `dificultad` pertenecen a los valores definidos.

  # La enumeración coincide con el largo de la respuesta, sin contar tildes ni espacios.
  validate :coincide_enumeracion_y_largo_respuesta, if: -> { enumeracion.present? }

  # TODO: Cada definición, indicador y material aparece textualmente en el enunciado.

  # TODO: La doble definición lleva 2 definiciones

  # TODO: Si el tipo es oculta, la respuesta está dentro del material, sin espacios. Si es anagrama, el material tiene exactamente las mismas letras que la respuesta. Si es iniciales o finales, las primeras o últimas letras del material forman la respuesta.



  # A partir de acá comienzan los métodos privados
  private

  def coincide_enumeracion_y_largo_respuesta
    if enumeracion != respuesta.length
      error.add(:enumeracion, "debe coincidir con el largo de la respuesta")
    end
  end



end
