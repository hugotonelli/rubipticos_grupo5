require "test_helper"

class TipoTest < ActiveSupport::TestCase
  test "los puntos deben ser un entero entre 10 y 1000" do
    tipo = tipos(:anagrama)
    [ 9, 1001, 50.5 ].each do |puntos|
      tipo.puntos = puntos
      assert_not tipo.valid?, "#{puntos} no debería ser válido"
    end
    tipo.puntos = 10
    assert tipo.valid?
  end

  test "el nombre es único" do
    assert_not Tipo.new(nombre: "anagrama", puntos: 100).valid?
  end

  test "solo acepta los tipos definidos en el enunciado" do
    assert_not Tipo.new(nombre: "palindromo", puntos: 100).valid?
  end

  test "se muestra con su nombre en castellano" do
    assert_equal "Doble definición", Tipo.new(nombre: "doble_definicion").to_s
  end
end
