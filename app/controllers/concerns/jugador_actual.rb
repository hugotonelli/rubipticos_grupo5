# Identifica al jugador del sitio público. No tiene cuenta: su token vive en una cookie firmada
# (si alguien la edita, Rails la descarta). En la cookie solo va el token; todo lo demás está en la base.
#
# - jugador_actual: el Jugador de la cookie, o nil (también disponible en las vistas).
# - requerir_jugador: before_action para las páginas que necesitan un jugador (por ejemplo, jugar).
#   Un jugador bloqueado por nombre ofensivo no puede seguir: tiene que crear un jugador nuevo.
# - recordar_jugador(jugador): guarda su token en la cookie.
module JugadorActual
  extend ActiveSupport::Concern

  # Otra cookie que la del login del backend (session_id).
  COOKIE = :jugador_token

  included do
    helper_method :jugador_actual
  end

  private

  def jugador_actual
    return @jugador_actual if defined?(@jugador_actual)

    token = cookies.signed[COOKIE]
    @jugador_actual = token.present? ? Jugador.find_by(token: token) : nil
  end

  def requerir_jugador
    if jugador_actual&.bloqueado?
      return redirect_to new_jugador_path,
                         alert: "Tu nombre fue bloqueado por un administrador. Para seguir jugando, creá un jugador nuevo."
    end
    return if jugador_actual

    # Para volver a donde estaba después de elegir el nombre (solo en pedidos de lectura).
    session[:volver_despues_de_elegir_nombre] = request.fullpath if request.get? || request.head?
    redirect_to new_jugador_path, notice: "Para jugar, primero elegí un nombre."
  end

  def recordar_jugador(jugador)
    cookies.signed.permanent[COOKIE] = { value: jugador.token, httponly: true, same_site: :lax }
    @jugador_actual = jugador
  end
end
