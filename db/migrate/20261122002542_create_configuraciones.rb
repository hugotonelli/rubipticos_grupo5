# Configuración general del juego editable desde el backend (una sola fila).
# Los puntos por tipo y los multiplicadores viven en sus propias tablas (tipos, dificultades).
class CreateConfiguraciones < ActiveRecord::Migration[8.1]
  def change
    create_table :configuraciones do |t|
      # URL completa del catálogo JSON (por ejemplo .../v1/cryptics.json). Es la URL completa y no
      # solo la base para poder apuntar también al catálogo de prueba cryptics_with_errors.json.
      t.string :url_fuente, null: false
      t.text :texto_bienvenida, null: false, default: ""

      t.timestamps
    end
  end
end
