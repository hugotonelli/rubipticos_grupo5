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

  test "el nombre es único sin distinguir mayúsculas, también con Ñ y tildes" do
    Jugador.create!(nombre: "Ñandú")

    assert_not Jugador.new(nombre: "ñandú").valid?
    assert_not Jugador.new(nombre: "ÑANDÚ").valid?
  end

  test "si la base rechaza un nombre repetido (dos altas al mismo tiempo), guardar lo informa sin romper" do
    Jugador.create!(nombre: "Simultaneo")
    jugador = Jugador.new(nombre: "simultaneo")
    def jugador.nombre_disponible = nil # simula que la validación pasó antes de que el otro se guardara

    assert_not jugador.guardar
    assert jugador.errors.of_kind?(:nombre, :taken)
  end
end
