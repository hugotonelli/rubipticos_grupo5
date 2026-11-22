require "test_helper"

class JugadorTest < ActiveSupport::TestCase
  test "el nombre tiene entre 3 y 20 caracteres" do
    assert_not Jugador.new(nombre: "Pe").valid?
    assert_not Jugador.new(nombre: "P" * 21).valid?
    assert Jugador.new(nombre: "Pep").valid?
  end

  test "el nombre es único sin distinguir mayúsculas" do
    assert_not Jugador.new(nombre: "PEDRITO").valid?
  end

  test "saca los espacios al principio y al final" do
    assert_equal "Juana", Jugador.new(nombre: "  Juana ").nombre
  end

  test "genera un token al crearse" do
    assert Jugador.create!(nombre: "Juana").token.present?
  end

  test "la racha se corta si no jugó ayer ni hoy" do
    jugador = jugadores(:pedrito)
    assert_equal 4, jugador.racha_vigente
    assert_equal 4, jugador.racha_vigente(Date.current + 1)
    assert_equal 0, jugador.racha_vigente(Date.current + 2)
  end

  test "visibles no incluye a los bloqueados" do
    assert_not_includes Jugador.visibles, jugadores(:bloqueado)
  end
end
