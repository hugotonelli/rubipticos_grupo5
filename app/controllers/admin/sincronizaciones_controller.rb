# Sincronización del catálogo desde el backend. Solo para administradores (el editor de puntajes
# no puede sincronizar): no declara permitir_editor_de_puntajes.
#
# La lógica está en SincronizadorDeCripticos; el controlador solo lo llama y muestra el resultado.
module Admin
  class SincronizacionesController < BaseController
    def index
      @configuracion = Configuracion.actual
      @sincronizaciones = Sincronizacion.includes(:user).recientes.limit(20)
    end

    # Botón «Sincronizar ahora».
    def create
      sincronizacion = SincronizadorDeCripticos.call(usuario: Current.user)

      if sincronizacion.fallida?
        redirect_to admin_sincronizacion_path(sincronizacion), alert: "La sincronización falló: #{sincronizacion.mensaje}", status: :see_other
      else
        redirect_to admin_sincronizacion_path(sincronizacion), notice: "Sincronización terminada: #{sincronizacion.resumen}.", status: :see_other
      end
    end

    # Informe de una sincronización.
    def show
      @sincronizacion = Sincronizacion.find(params.expect(:id))
    end
  end
end
