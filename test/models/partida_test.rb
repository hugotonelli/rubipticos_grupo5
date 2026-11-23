require "test_helper"

class PartidaTest < ActiveSupport::TestCase
  test "un jugador no puede jugar dos veces el mismo críptico" do
    repetida = Partida.new(jugador: jugadores(:pedrito), criptico: cripticos(:mora), iniciada_at: Time.current)
    assert_not repetida.valid?
    assert repetida.errors[:criptico_id].any?
  end

  test "como máximo 5 intentos y 4 pistas" do
    partida = partidas(:pedrito_mora)
    partida.intentos = 6
    assert_not partida.valid?
    partida.intentos = 5
    partida.pistas_usadas = 5
    assert_not partida.valid?
  end

  test "una partida terminada tiene fecha de fin" do
    partida = partidas(:pedrito_mora)
    partida.finalizada_at = nil
    assert_not partida.valid?
  end

  test "el tiempo lo calculan los timestamps del servidor" do
    inicio = Time.current
    partida = Partida.new(iniciada_at: inicio, finalizada_at: inicio + 240)
    assert_equal 240, partida.segundos
  end

  test "la base rechaza más de 5 intentos aunque se saltee la validación" do
    assert_raises(ActiveRecord::CheckViolation) do
      partidas(:pedrito_mora).update_column(:intentos, 9)
    end
  end

  test "estadísticas por críptico: jugadas, porcentaje resuelto y tiempo promedio" do
    inicio = 1.hour.ago
    rendida = Jugador.create!(nombre: "Rendido")
    en_curso = Jugador.create!(nombre: "Pensando")
    Partida.create!(jugador: rendida, criptico: cripticos(:mora), estado: :rendida,
                    iniciada_at: inicio, finalizada_at: inicio + 30)
    Partida.create!(jugador: en_curso, criptico: cripticos(:mora), iniciada_at: inicio)

    estadisticas = Partida.estadisticas_por_criptico([ cripticos(:mora).id ])[cripticos(:mora).id]

    assert_equal 3, estadisticas[:jugadas]
    assert_equal 50, estadisticas[:porcentaje_resuelto] # 1 resuelta de 2 terminadas
    assert_equal 60, estadisticas[:tiempo_promedio]     # la resuelta del fixture tardó 1 minuto
  end

  test "un críptico sin partidas no tiene estadísticas" do
    assert_equal Partida::SIN_ESTADISTICAS, cripticos(:camisa).estadisticas
  end
end
