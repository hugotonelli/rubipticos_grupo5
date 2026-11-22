require "test_helper"

class DificultadTest < ActiveSupport::TestCase
  test "el multiplicador puede ser decimal, mayor que 0 y hasta 5" do
    dificultad = dificultades(:facil)
    dificultad.multiplicador = 1.5
    assert dificultad.valid?

    [ 0, 5.01 ].each do |multiplicador|
      dificultad.multiplicador = multiplicador
      assert_not dificultad.valid?, "#{multiplicador} no debería ser válido"
    end
  end

  test "el nombre es único" do
    assert_not Dificultad.new(nombre: "facil", multiplicador: 1, tiempo: 60).valid?
  end

  test "solo acepta las dificultades definidas en el enunciado" do
    assert_not Dificultad.new(nombre: "experto", multiplicador: 4, tiempo: 600).valid?
  end

  test "se muestra con tilde y mayúscula" do
    assert_equal "Fácil", dificultades(:facil).to_s
  end
end
