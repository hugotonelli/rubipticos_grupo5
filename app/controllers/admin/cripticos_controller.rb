# Crípticos en el backend: listar con filtros, ver estadísticas y activar o desactivar.
# Solo para administradores (el editor de puntajes no puede editar crípticos).
# No hay alta ni baja: los crípticos entran por la sincronización y nunca se borran.
module Admin
  class CripticosController < BaseController
    FILTROS = %i[dificultad tipo estado origen].freeze

    before_action :set_criptico, only: %i[show update]

    def index
      @filtros = params.permit(*FILTROS).to_h.symbolize_keys
      @cripticos = Criptico.filtrar(**@filtros).includes(:tipo, :dificultad).ordenados
      @estadisticas = Partida.estadisticas_por_criptico(@cripticos.map(&:id))
    end

    def show
      @estadisticas = @criptico.estadisticas
    end

    # Activar o desactivar.
    def update
      activo = params.expect(criptico: [ :activo ])[:activo] == "true"

      if @criptico.cambiar_activo(activo)
        redirect_back_or_to admin_criptico_path(@criptico),
                            notice: "El críptico #{@criptico.id_fuente} quedó #{activo ? "activo" : "inactivo"}.",
                            status: :see_other
      else
        redirect_back_or_to admin_criptico_path(@criptico),
                            alert: "No se pudo cambiar: #{@criptico.errors.full_messages.to_sentence}",
                            status: :see_other
      end
    end

    private

    def set_criptico
      @criptico = Criptico.find(params.expect(:id))
    end
  end
end
