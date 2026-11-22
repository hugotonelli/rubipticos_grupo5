require "net/http"

# Trae el catálogo de crípticos desde la API (por HTTP) y lo guarda en la base.
#
#   sincronizacion = SincronizadorDeCripticos.call(usuario: Current.user)
#   sincronizacion.resumen  # => "42 creados, 0 actualizados, 0 desactivados, 0 rechazados"
#
# Reglas (enunciado, «Reglas de la sincronización»):
# 1. GET a la URL configurada con timeout de 10 s. Si falla la red o el JSON no parsea, no se toca nada.
# 2. Si la versión es la de la última sincronización exitosa: «Sin cambios».
# 3. Cada críptico se identifica por su id de la fuente: si no existe se crea; si cambió, se actualiza.
# 4. Un críptico inválido se saltea y se informa con su id y el motivo. Un id repetido dentro del
#    mismo catálogo también se rechaza (no se puede saber cuál de los dos es el correcto).
# 5. Un críptico que ya no viene en la fuente no se borra: se desactiva.
# 6. Cada sincronización queda registrada (modelo Sincronizacion), también las fallidas.
class SincronizadorDeCripticos
  TIMEOUT_SEGUNDOS = 10

  # Problema con la fuente (red, respuesta HTTP o JSON): la sincronización falla sin tocar nada.
  class ErrorDeFuente < StandardError; end

  def self.call(usuario:, url: Configuracion.actual.url_fuente)
    new(usuario: usuario, url: url).call
  end

  def initialize(usuario:, url:)
    @usuario = usuario
    @url = url
    @conteo = { creados: 0, actualizados: 0, desactivados: 0 }
    @rechazados = []
  end

  def call
    catalogo = leer_catalogo
    version = catalogo["version"].to_s

    return registrar(:sin_cambios, version: version) if version == Sincronizacion.ultima_version_exitosa

    Criptico.transaction do
      procesar(catalogo["cripticos"])
      registrar(:exitosa, version: version)
    end
  rescue ErrorDeFuente, ActiveRecord::ActiveRecordError => error
    fallar(error.message)
  rescue StandardError => error
    # Error no previsto: se reporta en el log para poder corregirlo, y el admin ve el informe de fallo.
    Rails.error.report(error, handled: true, context: { url: @url })
    fallar("Error inesperado al sincronizar (#{error.class}). Se registró en el log.")
  end

  private

  def leer_catalogo
    datos = JSON.parse(descargar)
    unless datos.is_a?(Hash) && datos["version"].present? && datos["cripticos"].is_a?(Array)
      raise ErrorDeFuente, "El JSON no tiene el formato esperado (faltan «version» o «cripticos»)."
    end

    datos
  rescue JSON::ParserError => error
    raise ErrorDeFuente, "El JSON de la fuente no se pudo leer: #{error.message}"
  end

  def descargar
    uri = URI.parse(@url)
    raise ErrorDeFuente, "La URL de la fuente tiene que ser http o https." unless uri.is_a?(URI::HTTP)

    respuesta = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                                open_timeout: TIMEOUT_SEGUNDOS, read_timeout: TIMEOUT_SEGUNDOS) do |http|
      http.get(uri.request_uri)
    end
    raise ErrorDeFuente, "La fuente respondió con el código HTTP #{respuesta.code}." unless respuesta.is_a?(Net::HTTPSuccess)

    respuesta.body.to_s.dup.force_encoding(Encoding::UTF_8)
  rescue Timeout::Error
    raise ErrorDeFuente, "La fuente no respondió en #{TIMEOUT_SEGUNDOS} segundos."
  rescue URI::InvalidURIError, SocketError, SystemCallError, IOError, OpenSSL::SSL::SSLError, Net::ProtocolError => error
    raise ErrorDeFuente, "No se pudo conectar con la fuente: #{error.message}"
  end

  def procesar(items)
    ids = items.map { |datos| datos.is_a?(Hash) ? datos["id"].to_s : "" }
    repetidos = ids.tally.select { |_id, cantidad| cantidad > 1 }.keys

    items.each do |datos|
      id = datos.is_a?(Hash) ? datos["id"].to_s : ""

      if id.blank?
        rechazar("(sin id)", "falta el id")
      elsif repetidos.include?(id)
        rechazar(id, "el id está repetido en el catálogo")
      else
        guardar(datos)
      end
    end

    desactivar_ausentes(ids.compact_blank)
  end

  def guardar(datos)
    criptico = Criptico.find_or_initialize_by(id_fuente: datos["id"].to_s)
    nuevo = criptico.new_record?
    criptico.assign_attributes(atributos(datos))

    # Vuelve a la fuente un críptico que había desactivado el sincronizador: se reactiva.
    # Uno que desactivó un administrador queda como está.
    if criptico.desactivado_por_sincronizacion?
      criptico.activo = true
      criptico.desactivado_por_sincronizacion = false
    end

    return rechazar(criptico.id_fuente, motivo_de_rechazo(criptico, datos)) unless criptico.valid?
    return unless criptico.changed?

    criptico.save!
    @conteo[nuevo ? :creados : :actualizados] += 1
  end

  # Traduce un críptico del JSON de la API a los atributos del modelo.
  def atributos(datos)
    {
      enunciado: datos["enunciado"],
      enumeracion: enumeracion(datos["enumeracion"]),
      respuesta: datos["respuesta"],
      definiciones: Array(datos["definiciones"]),
      indicadores: Array(datos["indicadores"]),
      materiales: Array(datos["material"]), # en el JSON la clave es «material», en singular
      tipo: Tipo.find_by(nombre: datos["tipo"]),
      dificultad: Dificultad.find_by(nombre: datos["dificultad"]),
      ayuda: datos["ayuda"],
      explicacion: datos["explicacion"],
      autor: datos["autor"],
      origen: datos["id"].to_s.start_with?("cr-") ? "catedra" : "propio"
    }
  end

  # "(6)" => 6. Si la respuesta tiene varias palabras, por ejemplo "(3,4)", se suman: 7.
  def enumeracion(texto)
    numeros = texto.to_s.scan(/\d+/)
    numeros.sum(&:to_i) if numeros.any?
  end

  def motivo_de_rechazo(criptico, datos)
    { tipo: "tipo", dificultad: "dificultad" }.each do |campo, nombre|
      next unless criptico.public_send(campo).nil? && datos[nombre].present?

      criptico.errors.delete(campo)
      criptico.errors.add(campo, "«#{datos[nombre]}» no existe")
    end
    criptico.errors.full_messages.to_sentence
  end

  def rechazar(id, motivo)
    @rechazados << { "id" => id, "motivo" => motivo }
  end

  def desactivar_ausentes(ids_en_la_fuente)
    @conteo[:desactivados] = Criptico.activos.where.not(id_fuente: ids_en_la_fuente)
                                     .update_all(activo: false, desactivado_por_sincronizacion: true,
                                                 updated_at: Time.current)
  end

  # La transacción ya deshizo cualquier cambio: se registra el fallo sin cantidades.
  def fallar(mensaje)
    @conteo.transform_values! { 0 }
    @rechazados = []
    registrar(:fallida, mensaje: mensaje)
  end

  def registrar(estado, version: nil, mensaje: nil)
    Sincronizacion.create!(
      user: @usuario,
      url: @url,
      estado: estado,
      version: version,
      mensaje: mensaje,
      **@conteo,
      rechazados: @rechazados.size,
      detalle_rechazados: @rechazados
    )
  end
end
