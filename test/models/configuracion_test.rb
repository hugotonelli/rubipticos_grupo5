require "test_helper"

class ConfiguracionTest < ActiveSupport::TestCase
  test "actual devuelve la fila existente" do
    assert_equal configuraciones(:actual), Configuracion.actual
  end

  test "actual la crea con la API de la cátedra si no existe" do
    Configuracion.delete_all
    assert_equal Configuracion::URL_CATEDRA, Configuracion.actual.url_fuente
  end

  test "la URL de la fuente tiene que ser http o https" do
    configuracion = configuraciones(:actual)
    configuracion.url_fuente = "archivo.json"
    assert_not configuracion.valid?
    configuracion.url_fuente = "http://localhost:4567/v1/cryptics_with_errors.json"
    assert configuracion.valid?
  end
end
