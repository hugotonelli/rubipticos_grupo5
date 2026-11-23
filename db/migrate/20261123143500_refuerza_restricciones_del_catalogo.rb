# Refuerza en la base lo que validan los modelos del catálogo:
#
# - La enumeración pasa a ser texto, como en la API: "(6)" o "(3,4)" si la respuesta tiene varias
#   palabras. Guardarla como número perdía cómo se divide la respuesta. Es obligatoria.
# - Tipo y dificultad solo pueden ser los valores del enunciado (check constraints): el criterio de
#   evaluación pide las validaciones «incluidas las de tipo» a nivel modelo y a nivel base.
# - Una sincronización que no falló siempre tiene versión.
class RefuerzaRestriccionesDelCatalogo < ActiveRecord::Migration[8.1]
  TIPOS = %w[anagrama oculta charada contenedor inversion supresion homofono doble_definicion
             iniciales finales sustitucion simbolos combinada].freeze
  DIFICULTADES = %w[facil medio avanzado].freeze

  def up
    change_column :cripticos, :enumeracion, :string
    execute "UPDATE cripticos SET enumeracion = '(' || enumeracion || ')' WHERE enumeracion IS NOT NULL"
    change_column_null :cripticos, :enumeracion, false
    add_check_constraint :cripticos, "enumeracion GLOB '(*)'", name: "cripticos_enumeracion_entre_parentesis"

    add_check_constraint :tipos, "nombre IN (#{lista(TIPOS)})", name: "tipos_nombre_valido"
    add_check_constraint :dificultades, "nombre IN (#{lista(DIFICULTADES)})", name: "dificultades_nombre_valido"

    add_check_constraint :sincronizaciones, "estado = 2 OR version IS NOT NULL", name: "sincronizaciones_version_si_no_fallo"
  end

  def down
    remove_check_constraint :sincronizaciones, name: "sincronizaciones_version_si_no_fallo"
    remove_check_constraint :dificultades, name: "dificultades_nombre_valido"
    remove_check_constraint :tipos, name: "tipos_nombre_valido"

    remove_check_constraint :cripticos, name: "cripticos_enumeracion_entre_parentesis"
    change_column_null :cripticos, :enumeracion, true
    execute "UPDATE cripticos SET enumeracion = replace(replace(enumeracion, '(', ''), ')', '')"
    change_column :cripticos, :enumeracion, :integer
  end

  private

  def lista(valores)
    valores.map { |valor| connection.quote(valor) }.join(", ")
  end
end
