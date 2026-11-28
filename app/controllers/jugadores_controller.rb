# Elegir nombre de jugador (primera visita). Crea el jugador y guarda su token en la cookie firmada.
# TODO (módulo de juego): cambiar el nombre (edit/update) y «empezar como otro jugador» (destroy de la cookie).
class JugadoresController < ApplicationController
  allow_unauthenticated_access

  def new
    return redirect_to new_partida_path if jugador_actual

    @jugador = Jugador.new
  end

  def create
    @jugador = Jugador.new(params.expect(jugador: [ :nombre ]))

    if @jugador.save
      recordar_jugador(@jugador)
      redirect_to session.delete(:volver_despues_de_elegir_nombre) || new_partida_path,
                  notice: "¡Hola, #{@jugador.nombre}!"
    else
      @sugerencia = SugeridorDeNombre.call(@jugador.nombre) if @jugador.errors.of_kind?(:nombre, :taken)
      render :new, status: :unprocessable_content
    end
  end
end
