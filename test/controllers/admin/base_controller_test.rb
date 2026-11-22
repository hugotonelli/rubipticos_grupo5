require "test_helper"

# Prueba los permisos de Admin::BaseController con un controlador de prueba
# que no declara permitir_editor_de_puntajes (o sea, solo para administradores).
class Admin::BaseControllerTest < ActionDispatch::IntegrationTest
  class SoloAdministradoresController < Admin::BaseController
    def index
      head :ok
    end
  end

  def con_ruta_de_prueba(&)
    with_routing do |rutas|
      rutas.draw do
        resource :session
        namespace :admin do
          root "inicio#index"
        end
        get "/admin/solo_administradores", to: "admin/base_controller_test/solo_administradores#index"
      end
      yield
    end
  end

  test "un administrador puede entrar" do
    con_ruta_de_prueba do
      sign_in_as users(:one)
      get "/admin/solo_administradores"
      assert_response :success
    end
  end

  test "un editor de puntajes es rechazado aunque escriba la URL a mano" do
    con_ruta_de_prueba do
      sign_in_as users(:two)
      get "/admin/solo_administradores"
      assert_redirected_to "/admin"
      assert_equal "No tenés permiso para entrar a esa sección.", flash[:alert]
    end
  end
end
