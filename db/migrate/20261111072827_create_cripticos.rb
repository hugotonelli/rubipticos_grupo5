class CreateCripticos < ActiveRecord::Migration[8.1]
  def change
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

      t.timestamps
    end
  end
end
