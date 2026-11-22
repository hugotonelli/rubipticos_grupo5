require "test_helper"

class NormalizadorDeTextoTest < ActiveSupport::TestCase
  test "ignora tildes, mayúsculas y espacios" do
    assert_equal "JAMON", NormalizadorDeTexto.call("jamon")
    assert_equal "JAMON", NormalizadorDeTexto.call("Jamón")
    assert_equal "JAMON", NormalizadorDeTexto.call(" JAMÓN ")
  end

  test "ignora signos y espacios intermedios" do
    assert_equal "GIRASOL", NormalizadorDeTexto.call("¡gira sol!")
  end

  test "distingue la Ñ de la N" do
    assert_equal "ÑANDU", NormalizadorDeTexto.call("ñandú")
    refute_equal NormalizadorDeTexto.call("año"), NormalizadorDeTexto.call("ano")
  end

  test "quita la diéresis" do
    assert_equal "PINGUINO", NormalizadorDeTexto.call("pingüino")
  end

  test "devuelve vacío con nil" do
    assert_equal "", NormalizadorDeTexto.call(nil)
  end
end
