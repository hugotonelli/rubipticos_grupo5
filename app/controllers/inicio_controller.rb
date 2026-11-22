class InicioController < ApplicationController
  allow_unauthenticated_access

  def index
    @configuracion = Configuracion.actual
  end
end
