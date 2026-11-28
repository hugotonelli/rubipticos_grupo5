# Propone un nombre libre parecido al pedido, para cuando ya está tomado:
#
#   SugeridorDeNombre.call("Pedrito")  # => "Pedrito_2" (o "Pedrito_3" si ese también está tomado)
#
# Respeta el largo máximo del nombre (20): si hace falta, acorta el original.
class SugeridorDeNombre
  LARGO_MAXIMO = 20

  def self.call(nombre)
    new(nombre).call
  end

  def initialize(nombre)
    @nombre = nombre.to_s.strip
  end

  def call
    (2..).each do |numero|
      sufijo = "_#{numero}"
      candidato = "#{@nombre.first(LARGO_MAXIMO - sufijo.length)}#{sufijo}"
      return candidato unless Jugador.where("lower(nombre) = ?", candidato.downcase).exists?
    end
  end
end
