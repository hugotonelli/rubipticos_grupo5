require "test_helper"

class Admin::SincronizacionesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @url = configuraciones(:actual).url_fuente
  end

  test "un administrador ve el botón y el historial" do
    sign_in_as users(:one)
    get admin_sincronizaciones_path

    assert_response :success
    assert_select "button", "Sincronizar ahora"
    assert_select "td", "2026-10-19.1"
  end

  test "el editor de puntajes no puede entrar aunque escriba la URL" do
    sign_in_as users(:two)

    get admin_sincronizaciones_path
    assert_redirected_to admin_root_path

    assert_no_difference -> { Sincronizacion.count } do
      post admin_sincronizaciones_path
    end
    assert_redirected_to admin_root_path
  end

  test "sincronizar ahora trae el catálogo y muestra el informe" do
    stub_request(:get, @url).to_return(body: file_fixture("cryptics.json").read)
    sign_in_as users(:one)

    assert_difference -> { Sincronizacion.count }, 1 do
      post admin_sincronizaciones_path
    end
    sincronizacion = Sincronizacion.recientes.first
    assert_redirected_to admin_sincronizacion_path(sincronizacion)
    assert_equal users(:one), sincronizacion.user

    follow_redirect!
    assert_select ".alert", /42 creados/
  end

  test "el informe muestra los rechazados con id y motivo" do
    stub_request(:get, @url).to_return(body: file_fixture("cryptics_with_errors.json").read)
    sign_in_as users(:one)

    post admin_sincronizaciones_path
    follow_redirect!

    assert_select "td code", "cr-105"
    assert_select "td", /«palindromo» no existe/
  end

  test "si la fuente falla, lo informa" do
    stub_request(:get, @url).to_timeout
    sign_in_as users(:one)

    post admin_sincronizaciones_path
    follow_redirect!

    assert_select ".alert-danger", /no respondió/
  end
end
