# - origen: de qué fuente vino el críptico ("catedra" o "propio"), para filtrar en el backend.
#   Se fija al sincronizar a partir del id (los crípticos propios usan un prefijo distinto de "cr-",
#   como pide el README de la API).
# - desactivado_por_sincronizacion: distingue un críptico que desactivó el sincronizador (porque ya no
#   venía en la fuente) de uno que desactivó un administrador. Si vuelve a aparecer en la fuente,
#   el sincronizador solo reactiva los primeros.
class AgregaOrigenACripticos < ActiveRecord::Migration[8.1]
  def change
    add_column :cripticos, :origen, :string, null: false, default: "catedra"
    add_column :cripticos, :desactivado_por_sincronizacion, :boolean, null: false, default: false
    add_index :cripticos, :origen
    add_check_constraint :cripticos, "origen IN ('catedra', 'propio')", name: "cripticos_origen_valido"
  end
end
