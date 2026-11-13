class CreateTipos < ActiveRecord::Migration[8.1]
  def change
    create_table :tipos do |t|
      t.string :tipo, null: false
      t.integer :puntos, null: false, default: 1
      t.text :descripcion

      t.timestamps
    end
  end
end
