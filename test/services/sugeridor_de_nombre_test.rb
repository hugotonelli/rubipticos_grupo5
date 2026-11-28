require "test_helper"

class SugeridorDeNombreTest < ActiveSupport::TestCase
  test "sugiere el nombre con _2" do
    assert_equal "Pedrito_2", SugeridorDeNombre.call("Pedrito")
  end

  test "si _2 también está tomado, sigue con _3, sin distinguir mayúsculas" do
    Jugador.create!(nombre: "PEDRITO_2")
    assert_equal "Pedrito_3", SugeridorDeNombre.call("Pedrito")
  end

  test "acorta el nombre para no pasarse de 20 caracteres" do
    sugerencia = SugeridorDeNombre.call("A" * 20)
    assert_equal 20, sugerencia.length
    assert sugerencia.end_with?("_2")
  end

  test "no sugiere un nombre tomado aunque tenga Ñ o tildes en otras mayúsculas" do
    Jugador.create!(nombre: "ÑANDÚ")
    Jugador.create!(nombre: "ñandú_2")

    assert_equal "ÑANDÚ_3", SugeridorDeNombre.call("ÑANDÚ")
  end
end
