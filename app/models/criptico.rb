class Criptico < ApplicationRecord
  # Palabras que solo unen partes del material y no cuentan para iniciales o finales.
  # Ejemplo: en cr-021 el material es "álbum, casa y amor" y la respuesta es MAR (álbuM, casA, amoR).
  PALABRAS_DE_UNION = %w[Y E O U NI].freeze

  # Enumeración como viene en la API: "(6)", o "(3,4)" si la respuesta tiene varias palabras.
  FORMATO_ENUMERACION = /\A\(\d+(,\d+)*\)\z/


  # Tipo y dificultad son tablas propias porque sus puntos y multiplicadores se editan desde el backend.
  belongs_to :tipo
  belongs_to :dificultad
  # No se borran crípticos jugados: se desactivan.
  has_many :partidas, dependent: :restrict_with_error

  scope :activos, -> { where(activo: true) }
  scope :inactivos, -> { where(activo: false) }
  scope :ordenados, -> { order(:id_fuente) }
  # Los que un jugador puede jugar en una dificultad: activos y que todavía no jugó.
  scope :disponibles_para, lambda { |jugador, dificultad|
    activos.where(dificultad: dificultad).where.not(id: jugador.partidas.select(:criptico_id))
  }

  # De qué fuente vino: el host de la URL desde la que se sincronizó (la API de la cátedra,
  # un fork o un servidor local). Lo fija el sincronizador.
  validates :origen, presence: true

  # Filtros del listado del backend (dificultad, tipo, estado y origen). Los vacíos se ignoran.
  #   Criptico.filtrar(dificultad: "facil", estado: "activos")
  def self.filtrar(dificultad: nil, tipo: nil, estado: nil, origen: nil)
    cripticos = all
    cripticos = cripticos.joins(:dificultad).where(dificultades: { nombre: dificultad }) if dificultad.present?
    cripticos = cripticos.joins(:tipo).where(tipos: { nombre: tipo }) if tipo.present?
    cripticos = cripticos.activos if estado == "activos"
    cripticos = cripticos.inactivos if estado == "inactivos"
    cripticos = cripticos.where(origen: origen) if origen.present?
    cripticos
  end

  # Activar o desactivar a mano desde el backend. Como lo decide un administrador,
  # el sincronizador ya no lo reactiva solo (ver SincronizadorDeCripticos).
  def cambiar_activo(activo)
    update(activo: activo, desactivado_por_sincronizacion: false)
  end

  # Estadísticas de juego de este críptico (ver Partida.estadisticas_por_criptico).
  def estadisticas
    Partida.estadisticas_por_criptico([ id ]).fetch(id, Partida::SIN_ESTADISTICAS)
  end

  # `enunciado`, `respuesta`, `tipo` y `dificultad` son obligatorios
  # (tipo y dificultad ya los exige `belongs_to`).
  validates :enunciado, :respuesta, presence: true
  # Identificador del críptico en la API de la cátedra: estable y nunca se reutiliza.
  validates :id_fuente, presence: true, uniqueness: true

  # `tipo` y `dificultad` pertenecen a los valores definidos: lo garantizan las claves foráneas
  # y la validación `inclusion` de Tipo y Dificultad.

  # La enumeración coincide con el largo de la respuesta, sin contar tildes ni espacios.
  validates :enumeracion, presence: true,
                          format: { with: FORMATO_ENUMERACION, message: "debe tener la forma (6) o (3,4)" }
  validate :coincide_enumeracion_y_largo_respuesta,
           if: -> { enumeracion.to_s.match?(FORMATO_ENUMERACION) && respuesta.present? }

  # Cada definición, indicador y material aparece textualmente en el enunciado (y no está vacío).
  validate :fragmentos_aparecen_en_el_enunciado, if: -> { enunciado.present? }

  # La doble definición lleva 2 definiciones y no tiene indicador ni material (anexo de la API).
  validate :doble_definicion_tiene_dos_definiciones, if: -> { tipo_es?("doble_definicion") }

  # Las reglas que hacen que el sistema verifique el juego de palabras por sí mismo.
  validate :respuesta_oculta_en_el_material, if: -> { tipo_es?("oculta") && respuesta.present? }
  validate :material_es_anagrama_de_la_respuesta, if: -> { tipo_es?("anagrama") && respuesta.present? }
  validate :iniciales_o_finales_forman_la_respuesta, if: -> { tipo_es?("iniciales", "finales") && respuesta.present? }

  # Cantidad total de letras de la enumeración: "(3,4)" => 7.
  def largo_enumeracion
    enumeracion.to_s.scan(/\d+/).sum(&:to_i)
  end

  private

  def tipo_es?(*nombres)
    nombres.include?(tipo&.nombre)
  end

  def respuesta_normalizada
    NormalizadorDeTexto.call(respuesta)
  end

  def material_normalizado
    NormalizadorDeTexto.call(materiales.join)
  end

  def coincide_enumeracion_y_largo_respuesta
    if largo_enumeracion != respuesta_normalizada.length
      errors.add(:enumeracion, "debe coincidir con el largo de la respuesta")
    end
  end

  def fragmentos_aparecen_en_el_enunciado
    { definiciones: definiciones, indicadores: indicadores, materiales: materiales }.each do |campo, fragmentos|
      Array(fragmentos).each do |fragmento|
        if fragmento.to_s.strip.empty?
          errors.add(campo, "no pueden tener fragmentos vacíos")
        elsif !enunciado.include?(fragmento.to_s)
          errors.add(campo, "«#{fragmento}» no aparece textualmente en el enunciado")
        end
      end
    end
  end

  def doble_definicion_tiene_dos_definiciones
    if Array(definiciones).size != 2
      errors.add(:definiciones, "de una doble definición tienen que ser 2")
    end
    errors.add(:indicadores, "tienen que estar vacíos en una doble definición") if Array(indicadores).any?
    errors.add(:materiales, "tiene que estar vacío en una doble definición") if Array(materiales).any?
  end

  # La respuesta está escrita de corrido dentro de un fragmento del material, sin contar espacios.
  def respuesta_oculta_en_el_material
    fragmentos = Array(materiales).map { |fragmento| NormalizadorDeTexto.call(fragmento.to_s) }
    unless fragmentos.any? { |fragmento| fragmento.include?(respuesta_normalizada) }
      errors.add(:respuesta, "no está oculta en el material")
    end
  end

  # El material tiene exactamente las mismas letras que la respuesta.
  def material_es_anagrama_de_la_respuesta
    if material_normalizado.chars.sort != respuesta_normalizada.chars.sort
      errors.add(:materiales, "no tiene exactamente las mismas letras que la respuesta")
    end
  end

  # Las primeras (o últimas) letras de las palabras del material forman la respuesta.
  # Se acepta contando todas las palabras o salteando las palabras de unión.
  def iniciales_o_finales_forman_la_respuesta
    palabras = palabras_del_material
    sin_union = palabras - PALABRAS_DE_UNION
    tomar_letra = tipo_es?("iniciales") ? ->(palabra) { palabra[0] } : ->(palabra) { palabra[-1] }

    candidatas = [ palabras, sin_union ].map { |lista| lista.map(&tomar_letra).join }
    unless candidatas.include?(respuesta_normalizada)
      errors.add(:respuesta, "no se forma con las #{tipo_es?("iniciales") ? "primeras" : "últimas"} letras del material")
    end
  end

  # Palabras del material, normalizadas y sin puntuación ("álbum, casa y amor" => ["ALBUM", "CASA", "Y", "AMOR"]).
  def palabras_del_material
    Array(materiales).flat_map { |fragmento| fragmento.to_s.split }
                     .map { |palabra| NormalizadorDeTexto.call(palabra) }
                     .reject(&:empty?)
  end
end
