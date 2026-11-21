require "test_helper"

class InicioControllerTest < ActionDispatch::IntegrationTest
  test "muestra la página de inicio sin iniciar sesión" do
    get root_url
    assert_response :success
  end
end
