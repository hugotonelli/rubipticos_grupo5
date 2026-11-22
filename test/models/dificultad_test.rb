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
    assert_not Dificultad.new(dificultad: "facil", multiplicador: 1, tiempo: 60).valid?
  end
end
