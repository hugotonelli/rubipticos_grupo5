require "test_helper"

class CripticoTest < ActiveSupport::TestCase
  test "el fixture es válido" do
    assert cripticos(:camisa).valid?
  end

  test "la enumeración debe coincidir con el largo de la respuesta" do
    criptico = cripticos(:camisa)
    criptico.enumeracion = 7
    assert_not criptico.valid?
    assert_includes criptico.errors[:enumeracion], "debe coincidir con el largo de la respuesta"
  end

  test "la enumeración no cuenta tildes ni espacios" do
    criptico = cripticos(:mora)
    criptico.respuesta = "MÓRA "
    assert criptico.valid?
  end

  test "enunciado y respuesta son obligatorios" do
    criptico = Criptico.new(tipo: tipos(:anagrama), dificultad: dificultades(:facil))
    assert_not criptico.valid?
    assert criptico.errors[:enunciado].any?
    assert criptico.errors[:respuesta].any?
  end

  test "es activo por defecto" do
    assert Criptico.new.activo
  end
end
