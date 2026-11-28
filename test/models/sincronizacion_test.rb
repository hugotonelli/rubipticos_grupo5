require "test_helper"

class SincronizacionTest < ActiveSupport::TestCase
  test "la última exitosa ignora las fallidas" do
    Sincronizacion.create!(user: users(:one), url: "https://x.test/c.json", estado: :fallida, mensaje: "timeout")
    assert_equal sincronizaciones(:inicial), Sincronizacion.ultima_exitosa
  end

  test "ya está sincronizada solo si coinciden la versión y la URL" do
    url = sincronizaciones(:inicial).url
    assert Sincronizacion.ya_sincronizada?(version: "2026-10-19.1", url: url)
    assert_not Sincronizacion.ya_sincronizada?(version: "otra", url: url)
    assert_not Sincronizacion.ya_sincronizada?(version: "2026-10-19.1", url: "http://localhost:4567/v1/cryptics.json")
  end

  test "una fallida necesita el motivo" do
    fallida = Sincronizacion.new(user: users(:one), url: "https://x.test/c.json", estado: :fallida)
    assert_not fallida.valid?
  end

  test "el resumen informa las cantidades" do
    assert_equal "34 creados, 0 actualizados, 0 desactivados, 0 rechazados", sincronizaciones(:inicial).resumen
  end
end
