# Pasa los crípticos a la convención de Rails: `id` numérico autoincremental y el
# identificador de la API en su propia columna `id_fuente` (única).
#
# Motivos:
# - Convention over configuration: el resto de las tablas (partidas, etc.) pueden
#   referenciar con `t.references :criptico` sin tener que declarar `type: :string`.
# - El id de la fuente es un dato externo; la clave primaria es nuestra.
#
# Además:
# - Se saca `version`: la versión es del catálogo entero, no de cada críptico.
#   Se va a guardar en el registro de cada sincronización.
# - Las listas (definiciones, indicadores, materiales) son siempre listas, nunca nulas.
#
# La tabla se recrea porque SQLite no permite cambiar el tipo de la clave primaria.
# No hay tablas que dependan de cripticos todavía, y los datos se recargan con db:seed.
class UsaIdNumericoEnCripticos < ActiveRecord::Migration[8.1]
  def up
    drop_table :cripticos

    create_table :cripticos do |t|
      t.string :id_fuente, null: false
      t.text :enunciado, null: false
      t.integer :enumeracion
      t.string :respuesta, null: false
      t.json :definiciones, null: false, default: []
      t.json :indicadores, null: false, default: []
      t.json :materiales, null: false, default: []
      t.text :ayuda
      t.text :explicacion
      t.string :autor
      t.boolean :activo, null: false, default: true
      t.references :tipo, null: false, foreign_key: true
      t.references :dificultad, null: false, foreign_key: true

      t.timestamps
    end
    add_index :cripticos, :id_fuente, unique: true
    add_index :cripticos, :activo
  end

  def down
    drop_table :cripticos

    create_table :cripticos, id: :string do |t|
      t.string :version
      t.text :enunciado, null: false
      t.integer :enumeracion
      t.string :respuesta, null: false
      t.text :ayuda
      t.text :explicacion
      t.string :autor
      t.json :definiciones
      t.json :indicadores
      t.json :materiales
      t.references :tipo, null: false, foreign_key: true
      t.references :dificultad, null: false, foreign_key: true
      t.boolean :activo, null: false, default: true

      t.timestamps
    end
    add_index :cripticos, :activo
  end
end
