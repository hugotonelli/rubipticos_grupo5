# Flujo de partida del sitio público (escrito a mano, no es un ABM):
#   new    → elegir dificultad; con ?dificultad=… muestra el botón «Jugar»
#   create → «Jugar»: asigna el críptico al azar y arranca el reloj (IniciadorDePartida)
#   show   → la partida: enunciado y enumeración (nunca la respuesta antes de terminar)
#
# TODO (módulo de juego): intentos, pistas, rendirse y resolver.
class PartidasController < ApplicationController
  allow_unauthenticated_access
  before_action :requerir_jugador

  def new
    # Si dejó una partida abierta, la retoma.
    en_curso = jugador_actual.partida_en_curso
    return redirect_to partida_path(en_curso) if en_curso

    @dificultad = Dificultad.find_by(nombre: params[:dificultad])
    @dificultades = Dificultad.order(:multiplicador)
    # Antes de mostrar «Jugar», se verifica que le queden crípticos de esa dificultad.
    @quedan_cripticos = @dificultad && Criptico.disponibles_para(jugador_actual, @dificultad).exists?
  end

  def create
    partida = IniciadorDePartida.call(jugador: jugador_actual, dificultad: params.expect(:dificultad))

    if partida.persisted?
      redirect_to partida_path(partida), status: :see_other
    else
      redirect_to new_partida_path, alert: partida.errors.full_messages.to_sentence, status: :see_other
    end
  end

  def show
    # Solo sus propias partidas: la de otro jugador da 404.
    @partida = jugador_actual.partidas.includes(criptico: %i[tipo dificultad]).find(params.expect(:id))
    @criptico = @partida.criptico
  end
end
