require "test_helper"

class JugadoresControllerTest < ActionDispatch::IntegrationTest
  test "elegir un nombre crea el jugador, guarda la cookie y lleva a jugar" do
    assert_difference -> { Jugador.count }, 1 do
      post jugador_path, params: { jugador: { nombre: "  Juana " } }
    end

    assert_redirected_to new_partida_path
    assert cookies[JugadorActual::COOKIE.to_s].present?
    assert_equal "Juana", Jugador.last.nombre

    follow_redirect!
    assert_select "h1", "¿Qué dificultad querés?"
  end

  test "si el nombre está tomado (sin importar mayúsculas), avisa y sugiere otro" do
    assert_no_difference -> { Jugador.count } do
      post jugador_path, params: { jugador: { nombre: "pedrito" } }
    end

    assert_response :unprocessable_content
    assert_select ".alert", /Pedrito_2|pedrito_2/
  end

  test "un nombre muy corto se rechaza" do
    post jugador_path, params: { jugador: { nombre: "Al" } }

    assert_response :unprocessable_content
    assert_select ".invalid-feedback"
  end

  test "si ya tiene jugador, no le pide nombre de nuevo" do
    jugar_como jugadores(:pedrito)
    get new_jugador_path

    assert_redirected_to new_partida_path
  end
end
