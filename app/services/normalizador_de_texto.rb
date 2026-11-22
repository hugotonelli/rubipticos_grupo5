# Normaliza un texto para comparar respuestas y contar letras, según el enunciado:
# sin tildes, sin mayúsculas, sin espacios ni signos. La Ñ se distingue de la N.
#
#   NormalizadorDeTexto.call(" Jamón ")  # => "JAMON"
#   NormalizadorDeTexto.call("Ñandú")    # => "ÑANDU"
class NormalizadorDeTexto
  # Marcador temporal para que la Ñ no pierda su tilde al quitar las demás.
  MARCA_ENIE = "\u0001"

  def self.call(texto)
    new(texto).call
  end

  def initialize(texto)
    @texto = texto.to_s
  end

  def call
    @texto
      .unicode_normalize(:nfc)
      .upcase
      .gsub("Ñ", MARCA_ENIE)
      .unicode_normalize(:nfd)
      .gsub(/\p{Mn}/, "")
      .gsub(MARCA_ENIE, "Ñ")
      .gsub(/[^A-Z0-9Ñ]/, "")
  end
end
