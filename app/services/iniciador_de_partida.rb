# Empieza una partida: elige al azar un críptico activo de la dificultad pedida que el jugador
# todavía no haya jugado, y arranca el reloj (iniciada_at, medido en el servidor).
#
#   partida = IniciadorDePartida.call(jugador: jugador_actual, dificultad: "facil")
#   partida.persisted?  # => false si no quedan crípticos o la dificultad no existe (ver partida.errors)
#
# El críptico se asigna recién al apretar «Jugar»: así no hay que guardar nada en el navegador
# mientras el jugador decide. Antes de mostrar el botón, la pantalla ya verifica que queden crípticos.
class IniciadorDePartida
  def self.call(jugador:, dificultad:)
    new(jugador: jugador, dificultad: dificultad).call
  end

  def initialize(jugador:, dificultad:)
    @jugador = jugador
    @dificultad = Dificultad.find_by(nombre: dificultad)
  end

  def call
    # Si dejó una partida abierta, se retoma esa en lugar de empezar otra.
    en_curso = @jugador.partida_en_curso
    return en_curso if en_curso

    partida = Partida.new(jugador: @jugador, estado: :en_curso)
    criptico = criptico_al_azar

    if @dificultad.nil?
      partida.errors.add(:base, "Elegí una dificultad.")
    elsif criptico.nil?
      partida.errors.add(:base, "Ya jugaste todos los crípticos de dificultad #{@dificultad}. ¡Probá otra!")
    else
      partida.criptico = criptico
      partida.iniciada_at = Time.current
      partida.save
    end
    partida
  rescue ActiveRecord::RecordNotUnique
    # Otro pedido del mismo jugador (otra pestaña, doble clic) empezó una partida al mismo tiempo:
    # la base rechazó la segunda por el índice único. Se retoma la que quedó.
    Partida.en_curso.find_by(jugador: @jugador) || partida
  end

  private

  def criptico_al_azar
    return if @dificultad.nil?

    Criptico.find_by(id: Criptico.disponibles_para(@jugador, @dificultad).pluck(:id).sample)
  end
end
