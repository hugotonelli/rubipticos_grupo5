# Ajusta las tablas del catálogo para que la base valide lo mismo que los modelos
# (el enunciado pide validar a nivel modelo y a nivel base).
class AjustaRestriccionesDelCatalogo < ActiveRecord::Migration[8.1]
  def up
    # Los crípticos que ya no vienen en la fuente se desactivan, no se borran.
    add_column :cripticos, :activo, :boolean, null: false, default: true
    add_index :cripticos, :activo

    # Nombres únicos: el sincronizador busca el tipo y la dificultad por nombre.
    add_index :tipos, :tipo, unique: true
    add_index :dificultades, :dificultad, unique: true

    # Puntos por tipo: entero entre 10 y 1000 (el default anterior, 1, quedaba fuera de rango).
    change_column_default :tipos, :puntos, from: 1, to: 100
    add_check_constraint :tipos, "puntos BETWEEN 10 AND 1000", name: "tipos_puntos_en_rango"

    # El multiplicador puede ser decimal (por ejemplo 1,5): mayor que 0 y hasta 5.
    change_column :dificultades, :multiplicador, :decimal, precision: 3, scale: 2, null: false, default: 1
    add_check_constraint :dificultades, "multiplicador > 0 AND multiplicador <= 5", name: "dificultades_multiplicador_en_rango"
    add_check_constraint :dificultades, "tiempo > 0", name: "dificultades_tiempo_positivo"
  end

  def down
    remove_check_constraint :dificultades, name: "dificultades_tiempo_positivo"
    remove_check_constraint :dificultades, name: "dificultades_multiplicador_en_rango"
    change_column :dificultades, :multiplicador, :integer, null: false, default: 1
    remove_check_constraint :tipos, name: "tipos_puntos_en_rango"
    change_column_default :tipos, :puntos, from: 100, to: 1
    remove_index :dificultades, :dificultad
    remove_index :tipos, :tipo
    remove_index :cripticos, :activo
    remove_column :cripticos, :activo
  end
end
