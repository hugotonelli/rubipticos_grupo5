require "test_helper"

class Admin::InicioControllerTest < ActionDispatch::IntegrationTest
  test "sin login redirige al ingreso" do
    get admin_root_path
    assert_redirected_to new_session_path
  end

  test "un administrador entra al panel" do
    sign_in_as users(:one)
    get admin_root_path
    assert_response :success
  end

  test "un editor de puntajes también entra al panel" do
    sign_in_as users(:two)
    get admin_root_path
    assert_response :success
  end

  test "un usuario desactivado con sesión abierta es expulsado" do
    sign_in_as users(:inactivo)
    get admin_root_path
    assert_redirected_to new_session_path
  end
end
