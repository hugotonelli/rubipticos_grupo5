require "test_helper"

class SincronizadorDeCripticosTest < ActiveSupport::TestCase
  URL = "https://ecorrons.github.io/cryptics-api/v1/cryptics.json".freeze

  setup do
    @admin = users(:one)
    @catalogo = JSON.parse(file_fixture("cryptics.json").read)
  end

  # Simula que la API devuelve este catálogo (un Hash, o un String con el cuerpo tal cual).
  def la_fuente_devuelve(catalogo, status: 200)
    cuerpo = catalogo.is_a?(String) ? catalogo : catalogo.to_json
    stub_request(:get, URL).to_return(status: status, body: cuerpo, headers: { "Content-Type" => "application/json" })
  end

  def sincronizar
    SincronizadorDeCripticos.call(usuario: @admin, url: URL)
  end

  def con_version(version, cripticos = @catalogo["cripticos"])
    @catalogo.merge("version" => version, "cripticos" => cripticos)
  end

  test "crea todos los crípticos del catálogo y registra la sincronización" do
    la_fuente_devuelve(@catalogo)

    sincronizacion = sincronizar

    assert sincronizacion.exitosa?
    assert_equal @catalogo["version"], sincronizacion.version
    assert_equal @catalogo["cripticos"].size, sincronizacion.creados
    assert_equal 0, sincronizacion.rechazados
    assert_equal @admin, sincronizacion.user

    camisa = Criptico.find_by!(id_fuente: "cr-013")
    assert_equal 6, camisa.enumeracion
    assert_equal [ "Mi", "el hogar" ], camisa.materiales
    assert_equal "contenedor", camisa.tipo.nombre
    assert_equal "catedra", camisa.origen
  end

  test "si la versión es la de la última sincronización exitosa, no hay cambios" do
    la_fuente_devuelve(@catalogo)
    sincronizar

    assert_no_changes -> { Criptico.maximum(:updated_at) } do
      assert sincronizar.sin_cambios?
    end
  end

  test "actualiza solo los crípticos que cambiaron" do
    la_fuente_devuelve(@catalogo)
    sincronizar

    cripticos = @catalogo["cripticos"].map(&:dup)
    cripticos.find { |datos| datos["id"] == "cr-013" }["ayuda"] = "Una ayuda nueva."
    la_fuente_devuelve(con_version("nueva", cripticos))

    sincronizacion = sincronizar

    assert_equal [ 0, 1 ], [ sincronizacion.creados, sincronizacion.actualizados ]
    assert_equal "Una ayuda nueva.", Criptico.find_by!(id_fuente: "cr-013").ayuda
  end

  test "desactiva los que ya no vienen y los reactiva si vuelven" do
    la_fuente_devuelve(@catalogo)
    sincronizar

    la_fuente_devuelve(con_version("sin-cr-013", @catalogo["cripticos"].reject { |datos| datos["id"] == "cr-013" }))
    assert_equal 1, sincronizar.desactivados
    assert_not Criptico.find_by!(id_fuente: "cr-013").activo

    la_fuente_devuelve(con_version("vuelve-cr-013"))
    sincronizar
    assert Criptico.find_by!(id_fuente: "cr-013").activo
  end

  test "no reactiva un críptico que desactivó un administrador" do
    la_fuente_devuelve(@catalogo)
    sincronizar
    Criptico.find_by!(id_fuente: "cr-013").update!(activo: false)

    la_fuente_devuelve(con_version("otra"))
    sincronizar

    assert_not Criptico.find_by!(id_fuente: "cr-013").activo
  end

  test "saltea los inválidos y los informa con id y motivo" do
    la_fuente_devuelve(JSON.parse(file_fixture("cryptics_with_errors.json").read))

    sincronizacion = sincronizar
    motivos = sincronizacion.detalle_rechazados.to_h { |rechazo| [ rechazo["id"], rechazo["motivo"] ] }

    assert sincronizacion.exitosa?
    assert_equal 0, sincronizacion.creados
    assert_equal 7, sincronizacion.rechazados
    assert_match "repetido", motivos["cr-101"]
    assert_match "Enumeración", motivos["cr-102"]
    assert_match "mismas letras", motivos["cr-103"]
    assert_match "Respuesta", motivos["cr-104"]
    assert_match "«palindromo» no existe", motivos["cr-105"]
    assert_match "«experto» no existe", motivos["cr-105"]
    assert_match "una planta", motivos["cr-107"]
  end

  test "un críptico con id propio queda con origen propio" do
    propio = @catalogo["cripticos"].first.merge("id" => "g5-001")
    la_fuente_devuelve(con_version("con-propio", [ propio ]))

    sincronizar

    assert_equal "propio", Criptico.find_by!(id_fuente: "g5-001").origen
  end

  test "si la fuente no responde, falla sin tocar nada" do
    stub_request(:get, URL).to_timeout

    assert_no_difference -> { Criptico.count } do
      sincronizacion = sincronizar
      assert sincronizacion.fallida?
      assert_match "no respondió", sincronizacion.mensaje
    end
  end

  test "si la fuente responde con error HTTP, falla" do
    la_fuente_devuelve("", status: 500)

    sincronizacion = sincronizar

    assert sincronizacion.fallida?
    assert_match "500", sincronizacion.mensaje
  end

  test "si el JSON no parsea, falla sin tocar nada" do
    la_fuente_devuelve("{ esto no es json")

    assert_no_difference -> { Criptico.count } do
      assert sincronizar.fallida?
    end
  end

  test "si el JSON no tiene versión ni crípticos, falla" do
    la_fuente_devuelve({ "otra" => "cosa" })

    assert_match "formato esperado", sincronizar.mensaje
  end

  test "una sincronización fallida no cuenta como última versión" do
    la_fuente_devuelve(@catalogo)
    sincronizar
    stub_request(:get, URL).to_timeout
    sincronizar

    la_fuente_devuelve(@catalogo)
    assert sincronizar.sin_cambios?
  end

  test "un error inesperado queda registrado como fallida y no rompe la pantalla" do
    la_fuente_devuelve(@catalogo)
    sincronizador = SincronizadorDeCripticos.new(usuario: @admin, url: URL)
    def sincronizador.procesar(_items) = raise(NoMethodError, "algo que no previmos")

    sincronizacion = sincronizador.call

    assert sincronizacion.fallida?
    assert_match "Error inesperado", sincronizacion.mensaje
    assert_equal 0, Criptico.where(id_fuente: "cr-013").count
  end

  test "si falta el tipo, el motivo lo dice una sola vez" do
    sin_tipo = @catalogo["cripticos"].first.merge("tipo" => nil)
    la_fuente_devuelve(con_version("sin-tipo", [ sin_tipo ]))

    motivo = sincronizar.detalle_rechazados.first["motivo"]

    assert_equal 1, motivo.scan("Tipo").size, motivo
  end
end
