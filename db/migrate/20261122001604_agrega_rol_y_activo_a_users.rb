# Usuarios del backend: cada uno tiene un rol (administrador o editor de puntajes)
# y puede ser desactivado por un administrador.
class AgregaRolYActivoAUsers < ActiveRecord::Migration[8.1]
  def change
    # 0 = editor_puntajes (el de menos permisos, por defecto), 1 = administrador. Ver User.
    add_column :users, :rol, :integer, null: false, default: 0
    add_column :users, :activo, :boolean, null: false, default: true
    add_check_constraint :users, "rol IN (0, 1)", name: "users_rol_valido"
  end
end
