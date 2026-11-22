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
end
