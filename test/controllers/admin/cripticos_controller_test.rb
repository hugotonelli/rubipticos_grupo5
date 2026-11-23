require "test_helper"

class Admin::CripticosControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "lista los crípticos con sus estadísticas" do
    get admin_cripticos_path

    assert_response :success
    assert_select "td a", "prueba-003"
    assert_select "td a", "prueba-013"
    assert_select "td", "100 %" # MORA: 1 resuelta de 1 terminada
  end

  test "filtra por dificultad" do
    get admin_cripticos_path, params: { dificultad: "medio" }

    assert_select "td a", "prueba-013"
    assert_select "td a", { text: "prueba-003", count: 0 }
  end

  test "muestra el detalle con la respuesta y las estadísticas" do
    get admin_criptico_path(cripticos(:mora))

    assert_response :success
    assert_select "strong", "MORA"
    assert_select "div", "1 min 0 s"
  end

  test "desactiva y vuelve a activar" do
    criptico = cripticos(:mora)

    patch admin_criptico_path(criptico), params: { criptico: { activo: false } }
    assert_redirected_to admin_criptico_path(criptico)
    assert_not criptico.reload.activo

    patch admin_criptico_path(criptico), params: { criptico: { activo: true } }
    assert criptico.reload.activo
  end

  test "el editor de puntajes no puede ver ni cambiar crípticos" do
    sign_in_as users(:two)

    get admin_cripticos_path
    assert_redirected_to admin_root_path

    patch admin_criptico_path(cripticos(:mora)), params: { criptico: { activo: false } }
    assert_redirected_to admin_root_path
    assert cripticos(:mora).reload.activo
  end
end
