# Datos iniciales. Este script tiene que poder correrse varias veces sin duplicar nada
# (por eso find_or_create_by!), y lo usa `bin/rails db:setup`.
#
# Los nombres de tipo y dificultad son los mismos que usa la API de la cátedra
# (sin tildes: "facil", "inversion", ...), porque el sincronizador los busca por ese valor.

[
  { nombre: "facil", multiplicador: 1, tiempo: 60 },
  { nombre: "medio", multiplicador: 2, tiempo: 180 },
  { nombre: "avanzado", multiplicador: 3, tiempo: 300 }
].each do |atributos|
  Dificultad.find_or_create_by!(nombre: atributos[:nombre]) do |dificultad|
    dificultad.assign_attributes(atributos)
  end
end

[
  { nombre: "anagrama", descripcion: "Reordenar las letras del material." },
  { nombre: "oculta", descripcion: "La respuesta está escrita de corrido dentro del material." },
  { nombre: "charada", descripcion: "Se pegan piezas una detrás de otra." },
  { nombre: "contenedor", descripcion: "Una pieza va dentro de otra." },
  { nombre: "inversion", descripcion: "El material se lee al revés." },
  { nombre: "supresion", descripcion: "Se quita una letra del principio, del final o del medio." },
  { nombre: "homofono", descripcion: "Una palabra que suena igual a otra. En castellano: h muda, b/v, s/c/z, ll/y." },
  { nombre: "doble_definicion", descripcion: "Dos definiciones de la misma palabra. No hay indicador ni material." },
  { nombre: "iniciales", descripcion: "Las primeras letras de palabras seguidas." },
  { nombre: "finales", descripcion: "Las últimas letras de palabras seguidas." },
  { nombre: "sustitucion", descripcion: "Se cambia una letra por otra." },
  { nombre: "simbolos", descripcion: "Abreviaturas convencionales: números romanos, puntos cardinales, elementos químicos, notas musicales." },
  { nombre: "combinada", descripcion: "Dos o más operaciones en el mismo enunciado." }
].each do |atributos|
  Tipo.find_or_create_by!(nombre: atributos[:nombre]) do |tipo|
    tipo.descripcion = atributos[:descripcion]
    tipo.puntos = 100
  end
end

# Configuración general (URL de la API de la cátedra y texto de bienvenida).
Configuracion.actual

# Admin de prueba (las credenciales están en el README).
User.find_or_create_by!(email_address: "admin@rubipticos.com") do |user|
  user.password = "rubipticos"
  user.rol = :administrador
end

# TODO: reemplazar por el SincronizadorDeCripticos (el enunciado pide que db:seed use el mismo sincronizador).
Criptico.find_or_create_by!(id_fuente: "cr-013") do |criptico|
  criptico.assign_attributes(
    enunciado: "Mi metido en el hogar da una prenda",
    enumeracion: 6,
    respuesta: "CAMISA",
    definiciones: [ "una prenda" ],
    indicadores: [ "metido en" ],
    materiales: [ "Mi", "el hogar" ],
    tipo: Tipo.find_by!(nombre: "contenedor"),
    dificultad: Dificultad.find_by!(nombre: "medio"),
    ayuda: "El hogar es una palabra de cuatro letras. Partila al medio y meté MI.",
    explicacion: "MI dentro de CASA (el hogar): CA + MI + SA = CAMISA.",
    autor: "Cátedra"
  )
end
