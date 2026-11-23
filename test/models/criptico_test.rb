require "test_helper"

class CripticoTest < ActiveSupport::TestCase
  # Arma un críptico válido de tipo oculta y le aplica los cambios que recibe.
  def criptico(**cambios)
    Criptico.new({
      id_fuente: "prueba-1",
      enunciado: "La cama tejida esconde la infusión argentina",
      enumeracion: 4,
      respuesta: "MATE",
      definiciones: [ "la infusión argentina" ],
      indicadores: [ "esconde" ],
      materiales: [ "cama tejida" ],
      tipo: tipos(:oculta),
      dificultad: dificultades(:facil)
    }.merge(cambios))
  end

  # Convierte un críptico del JSON de la API en un Criptico, como lo va a hacer el sincronizador.
  def desde_json(datos)
    Criptico.new(
      id_fuente: datos["id"],
      enunciado: datos["enunciado"],
      enumeracion: datos["enumeracion"].to_s[/\d+/],
      respuesta: datos["respuesta"],
      definiciones: datos["definiciones"],
      indicadores: datos["indicadores"],
      materiales: datos["material"],
      tipo: Tipo.find_by(nombre: datos["tipo"]),
      dificultad: Dificultad.find_by(nombre: datos["dificultad"]),
      ayuda: datos["ayuda"],
      explicacion: datos["explicacion"],
      autor: datos["autor"]
    )
  end

  def catalogo(archivo)
    JSON.parse(file_fixture(archivo).read)["cripticos"]
  end

  test "el fixture es válido" do
    assert cripticos(:camisa).valid?
  end

  test "enunciado y respuesta son obligatorios" do
    sin_datos = criptico(enunciado: nil, respuesta: nil)
    assert_not sin_datos.valid?
    assert sin_datos.errors[:enunciado].any?
    assert sin_datos.errors[:respuesta].any?
  end

  test "el id de la fuente es obligatorio y único" do
    repetido = cripticos(:mora).dup
    assert_not repetido.valid?
    assert repetido.errors[:id_fuente].any?
  end

  test "es activo por defecto" do
    assert Criptico.new.activo
  end

  test "la enumeración debe coincidir con el largo de la respuesta" do
    invalido = criptico(enumeracion: 5)
    assert_not invalido.valid?
    assert_includes invalido.errors.full_messages, "Enumeración debe coincidir con el largo de la respuesta"
  end

  test "la enumeración no cuenta tildes ni espacios" do
    assert criptico(respuesta: "MÁTE ").valid?
  end

  test "cada definición, indicador y material aparece textualmente en el enunciado" do
    assert_not criptico(definiciones: [ "una planta" ]).valid?
    assert_not criptico(indicadores: [ "guarda" ]).valid?
    assert_not criptico(materiales: [ "cama tejido" ]).valid?
  end

  test "la doble definición lleva 2 definiciones" do
    doble = criptico(
      enunciado: "Felino o herramienta para cambiar la rueda", respuesta: "GATO",
      definiciones: [ "Felino" ], indicadores: [], materiales: [], tipo: tipos(:doble_definicion)
    )
    assert_not doble.valid?

    doble.definiciones = [ "Felino", "herramienta para cambiar la rueda" ]
    assert doble.valid?
  end

  test "en una oculta la respuesta está dentro del material" do
    assert criptico.valid?
    assert_not criptico(respuesta: "TEJA", enumeracion: 4, materiales: [ "La cama" ]).valid?
  end

  test "en un anagrama el material tiene exactamente las mismas letras" do
    anagrama = criptico(
      enunciado: "Amor loco da una fruta del bosque", respuesta: "MORA",
      definiciones: [ "una fruta del bosque" ], indicadores: [ "loco" ], materiales: [ "Amor" ],
      tipo: tipos(:anagrama)
    )
    assert anagrama.valid?

    anagrama.respuesta = "ROMO"
    assert_not anagrama.valid?
  end

  test "en iniciales las primeras letras forman la respuesta" do
    iniciales = criptico(
      enunciado: "Al principio, ocho sapos observan un animal peludo", enumeracion: 3, respuesta: "OSO",
      definiciones: [ "un animal peludo" ], indicadores: [ "Al principio" ], materiales: [ "ocho sapos observan" ],
      tipo: tipos(:iniciales)
    )
    assert iniciales.valid?

    iniciales.respuesta = "OSA"
    assert_not iniciales.valid?
  end

  test "en finales se ignoran la puntuación y las palabras de unión" do
    finales = criptico(
      enunciado: "Colas de álbum, casa y amor dan agua salada", enumeracion: 3, respuesta: "MAR",
      definiciones: [ "agua salada" ], indicadores: [ "Colas de" ], materiales: [ "álbum, casa y amor" ],
      tipo: tipos(:finales)
    )
    assert finales.valid?
  end

  test "los crípticos del catálogo real de la cátedra son todos válidos" do
    catalogo("cryptics.json").each do |datos|
      criptico = desde_json(datos)
      assert criptico.valid?, "#{datos["id"]}: #{criptico.errors.full_messages.to_sentence}"
    end
  end

  test "el catálogo con errores se rechaza por el motivo correcto" do
    errores = catalogo("cryptics_with_errors.json").index_by { |datos| datos["id"] }.transform_values do |datos|
      criptico = desde_json(datos)
      criptico.valid?
      criptico.errors
    end

    assert errores["cr-102"][:enumeracion].any?, "cr-102: enumeración (6) para BANCO"
    assert errores["cr-103"][:materiales].any?, "cr-103: MONJA no es anagrama de JAMÁS"
    assert errores["cr-104"][:respuesta].any?, "cr-104: falta la respuesta"
    assert errores["cr-105"][:tipo].any?, "cr-105: tipo palindromo no existe"
    assert errores["cr-105"][:dificultad].any?, "cr-105: dificultad experto no existe"
    assert errores["cr-107"][:definiciones].any?, "cr-107: «una planta» no está en el enunciado"
  end

  test "filtra por dificultad, tipo, estado y origen" do
    cripticos(:camisa).update!(activo: false)

    assert_equal [ cripticos(:mora) ], Criptico.filtrar(dificultad: "facil").to_a
    assert_equal [ cripticos(:camisa) ], Criptico.filtrar(tipo: "contenedor").to_a
    assert_equal [ cripticos(:camisa) ], Criptico.filtrar(estado: "inactivos").to_a
    assert_equal [ cripticos(:mora) ], Criptico.filtrar(estado: "activos").to_a
    assert_empty Criptico.filtrar(origen: "propio")
    assert_equal 2, Criptico.filtrar(dificultad: "", tipo: nil).count
  end

  test "desactivarlo a mano evita que el sincronizador lo reactive" do
    criptico = cripticos(:mora)
    criptico.update!(activo: false, desactivado_por_sincronizacion: true)

    criptico.cambiar_activo(false)

    assert_not criptico.reload.desactivado_por_sincronizacion
  end
end
