require "test_helper"

class SincronizacionTest < ActiveSupport::TestCase
  test "la última versión exitosa ignora las fallidas y las sin cambios" do
    Sincronizacion.create!(user: users(:one), url: "https://x.test/c.json", estado: :fallida, mensaje: "timeout")
    assert_equal "2026-10-19.1", Sincronizacion.ultima_version_exitosa
  end

  test "una fallida necesita el motivo" do
    fallida = Sincronizacion.new(user: users(:one), url: "https://x.test/c.json", estado: :fallida)
    assert_not fallida.valid?
  end

  test "el resumen informa las cantidades" do
    assert_equal "34 creados, 0 actualizados, 0 desactivados, 0 rechazados", sincronizaciones(:inicial).resumen
  end
end
