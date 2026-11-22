require "test_helper"

# Prueba los permisos de Admin::BaseController con un controlador de prueba
# que no declara permitir_editor_de_puntajes (o sea, solo para administradores).
class Admin::BaseControllerTest < ActionDispatch::IntegrationTest
  class SoloAdministradoresController < Admin::BaseController
    def index
      head :ok
    end
  end

  setup do
    Rails.application.routes.disable_clear_and_finalize = true
    Rails.application.routes.draw do
      get "/admin/solo_administradores", to: "admin/base_controller_test/solo_administradores#index"
    end
  end

  teardown { Rails.application.reload_routes! }

  test "un administrador puede entrar" do
    sign_in_as users(:one)
    get "/admin/solo_administradores"
    assert_response :success
  end

  test "un editor de puntajes es rechazado aunque escriba la URL a mano" do
    sign_in_as users(:two)
    get "/admin/solo_administradores"
    assert_redirected_to admin_root_path
    assert_equal "No tenés permiso para entrar a esa sección.", flash[:alert]
  end
end
