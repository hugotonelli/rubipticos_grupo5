# Portada del backend. La ven los dos roles.
module Admin
  class InicioController < BaseController
    permitir_editor_de_puntajes

    def index
    end
  end
end
