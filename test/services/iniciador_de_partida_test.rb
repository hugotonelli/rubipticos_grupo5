require "test_helper"

class IniciadorDePartidaTest < ActiveSupport::TestCase
  setup { @jugador = Jugador.create!(nombre: "Nueva") }

  test "asigna un críptico activo de la dificultad elegida y arranca el reloj en el servidor" do
    freeze_time do
      partida = IniciadorDePartida.call(jugador: @jugador, dificultad: "medio")

      assert partida.persisted?
      assert partida.en_curso?
      assert_equal cripticos(:camisa), partida.criptico
      assert_equal Time.current, partida.iniciada_at
    end
  end

  test "no asigna un críptico que el jugador ya jugó" do
    partida = IniciadorDePartida.call(jugador: jugadores(:pedrito), dificultad: "facil")

    assert_not partida.persisted?
    assert_match "Ya jugaste todos", partida.errors.full_messages.to_sentence
  end

  test "no asigna crípticos inactivos" do
    cripticos(:camisa).update!(activo: false)

    assert_not IniciadorDePartida.call(jugador: @jugador, dificultad: "medio").persisted?
  end

  test "si tiene una partida en curso, la retoma en lugar de empezar otra" do
    primera = IniciadorDePartida.call(jugador: @jugador, dificultad: "medio")

    assert_no_difference -> { Partida.count } do
      assert_equal primera, IniciadorDePartida.call(jugador: @jugador, dificultad: "facil")
    end
  end

  test "con una dificultad que no existe, no crea nada" do
    partida = IniciadorDePartida.call(jugador: @jugador, dificultad: "experto")

    assert_not partida.persisted?
    assert_includes partida.errors.full_messages, "Elegí una dificultad."
  end

  test "la base no permite dos partidas en curso para el mismo jugador" do
    IniciadorDePartida.call(jugador: @jugador, dificultad: "medio")

    assert_raises(ActiveRecord::RecordNotUnique) do
      Partida.new(jugador: @jugador, criptico: cripticos(:mora), iniciada_at: Time.current).save(validate: false)
    end
  end
end
