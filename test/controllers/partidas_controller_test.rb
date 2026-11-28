require "test_helper"

class PartidasControllerTest < ActionDispatch::IntegrationTest
  setup { @jugador = Jugador.create!(nombre: "Nueva") }

  test "sin jugador, primero pide el nombre y después vuelve a jugar" do
    get new_partida_path(dificultad: "medio")
    assert_redirected_to new_jugador_path

    post jugador_path, params: { jugador: { nombre: "Recien" } }
    assert_redirected_to new_partida_path(dificultad: "medio")
  end

  test "muestra las dificultades y después el botón Jugar" do
    jugar_como @jugador

    get new_partida_path
    assert_select "h2", "Fácil"
    assert_select "h2", "Avanzado"

    get new_partida_path(dificultad: "medio")
    assert_select "button", "Jugar"
  end

  test "Jugar crea la partida y muestra el enunciado sin la respuesta" do
    jugar_como @jugador

    assert_difference -> { Partida.count }, 1 do
      post partidas_path, params: { dificultad: "medio" }
    end
    partida = Partida.last
    assert_redirected_to partida_path(partida)

    follow_redirect!
    assert_select "p", cripticos(:camisa).enunciado
    assert_select "p", "(6)"
    assert_no_match "CAMISA", response.body, "la respuesta nunca viaja al navegador antes de terminar"
  end

  test "si dejó una partida abierta, al volver a Jugar la retoma" do
    jugar_como @jugador
    post partidas_path, params: { dificultad: "medio" }
    partida = Partida.last

    get new_partida_path
    assert_redirected_to partida_path(partida)
  end

  test "si no quedan crípticos de esa dificultad, lo avisa" do
    jugar_como jugadores(:pedrito)

    post partidas_path, params: { dificultad: "facil" }

    assert_redirected_to new_partida_path
    assert_match "Ya jugaste todos", flash[:alert]
  end

  test "no se puede ver la partida de otro jugador" do
    jugar_como @jugador

    get partida_path(partidas(:pedrito_mora))

    assert_response :not_found
  end

  test "un jugador bloqueado no puede jugar y puede crear uno nuevo" do
    jugar_como jugadores(:bloqueado)

    get new_partida_path
    assert_redirected_to new_jugador_path
    assert_match "bloqueado", flash[:alert]

    follow_redirect!
    assert_response :success
    assert_select "h1", "Elegí tu nombre"

    post jugador_path, params: { jugador: { nombre: "Arrepentido" } }
    assert_redirected_to new_partida_path
    follow_redirect!
    assert_response :success
  end

  test "si no le quedan crípticos de esa dificultad, no muestra el botón Jugar" do
    jugar_como jugadores(:pedrito)

    get new_partida_path(dificultad: "facil")

    assert_select "button", { text: "Jugar", count: 0 }
    assert_select ".alert", /Ya jugaste todos/
  end
end
