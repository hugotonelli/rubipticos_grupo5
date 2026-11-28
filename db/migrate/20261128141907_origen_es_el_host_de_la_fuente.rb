# El «origen» de un críptico pasa a ser el host de la URL desde la que se sincronizó
# (la API de la cátedra, un fork o un servidor local), como respondió la cátedra en el foro.
# Antes se deducía del prefijo del id ("catedra" o "propio").
class OrigenEsElHostDeLaFuente < ActiveRecord::Migration[8.1]
  HOST_CATEDRA = "ecorrons.github.io".freeze

  def up
    remove_check_constraint :cripticos, name: "cripticos_origen_valido"
    change_column_default :cripticos, :origen, from: "catedra", to: nil
    # Los crípticos ya cargados vinieron de la API de la cátedra.
    execute "UPDATE cripticos SET origen = #{connection.quote(HOST_CATEDRA)}"
  end

  def down
    execute "UPDATE cripticos SET origen = 'catedra'"
    change_column_default :cripticos, :origen, from: nil, to: "catedra"
    add_check_constraint :cripticos, "origen IN ('catedra', 'propio')", name: "cripticos_origen_valido"
  end
end
