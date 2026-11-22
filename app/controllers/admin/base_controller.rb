# Base de todos los controladores del backend (/admin).
#
# - Exige login (lo hace ApplicationController con el concern Authentication).
# - Rechaza usuarios desactivados.
# - Por defecto, solo deja pasar administradores. Un controlador que también puede usar
#   el editor de puntajes lo declara con `permitir_editor_de_puntajes`.
#
# Los permisos se controlan acá, en el servidor: ocultar links del menú no alcanza.
module Admin
  class BaseController < ApplicationController
    layout "admin"

    before_action :rechazar_usuario_inactivo
    before_action :requerir_administrador

    def self.permitir_editor_de_puntajes(**opciones)
      skip_before_action :requerir_administrador, **opciones
    end

    private

    def rechazar_usuario_inactivo
      return if Current.user.activo?

      terminate_session
      redirect_to new_session_path, alert: "Tu usuario está desactivado."
    end

    def requerir_administrador
      return if Current.user.administrador?

      redirect_to admin_root_path, alert: "No tenés permiso para entrar a esa sección."
    end
  end
end
