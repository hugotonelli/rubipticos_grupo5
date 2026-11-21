class CreateDificultades < ActiveRecord::Migration[8.1]
  def change
    create_table :dificultades do |t|
      t.string :dificultad, null: false
      t.integer :multiplicador, null: false, default: 1
      t.integer :tiempo, null: false, default: 60

      t.timestamps
    end
  end
end
