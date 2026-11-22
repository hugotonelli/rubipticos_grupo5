# `tipo.tipo` y `dificultad.dificultad` se leían raro: pasan a ser `tipo.nombre` y `dificultad.nombre`.
# El valor es el identificador que usa la API ("anagrama", "facil", ...).
class RenombraNombreEnTiposYDificultades < ActiveRecord::Migration[8.1]
  def change
    rename_column :tipos, :tipo, :nombre
    rename_column :dificultades, :dificultad, :nombre
  end
end
