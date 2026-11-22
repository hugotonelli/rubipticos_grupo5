# Datos iniciales. Este script tiene que poder correrse varias veces sin duplicar nada
# (por eso find_or_create_by!), y lo usa `bin/rails db:setup`.
#
# Los nombres de tipo y dificultad son los mismos que usa la API de la cátedra
# (sin tildes: "facil", "inversion", ...), porque el sincronizador los busca por ese valor.

[
  { dificultad: "facil", multiplicador: 1, tiempo: 60 },
  { dificultad: "medio", multiplicador: 2, tiempo: 180 },
  { dificultad: "avanzado", multiplicador: 3, tiempo: 300 }
].each do |atributos|
  Dificultad.find_or_create_by!(dificultad: atributos[:dificultad]) do |dificultad|
    dificultad.assign_attributes(atributos)
  end
end

[
  { tipo: "anagrama", descripcion: "Reordenar las letras del material." },
  { tipo: "oculta", descripcion: "La respuesta está escrita de corrido dentro del material." },
  { tipo: "charada", descripcion: "Se pegan piezas una detrás de otra." },
  { tipo: "contenedor", descripcion: "Una pieza va dentro de otra." },
  { tipo: "inversion", descripcion: "El material se lee al revés." },
  { tipo: "supresion", descripcion: "Se quita una letra del principio, del final o del medio." },
  { tipo: "homofono", descripcion: "Una palabra que suena igual a otra. En castellano: h muda, b/v, s/c/z, ll/y." },
  { tipo: "doble_definicion", descripcion: "Dos definiciones de la misma palabra. No hay indicador ni material." },
  { tipo: "iniciales", descripcion: "Las primeras letras de palabras seguidas." },
  { tipo: "finales", descripcion: "Las últimas letras de palabras seguidas." },
  { tipo: "sustitucion", descripcion: "Se cambia una letra por otra." },
  { tipo: "simbolos", descripcion: "Abreviaturas convencionales: números romanos, puntos cardinales, elementos químicos, notas musicales." },
  { tipo: "combinada", descripcion: "Dos o más operaciones en el mismo enunciado." }
].each do |atributos|
  Tipo.find_or_create_by!(tipo: atributos[:tipo]) do |tipo|
    tipo.descripcion = atributos[:descripcion]
    tipo.puntos = 100
  end
end

# Admin de prueba. TODO: asignarle el rol de administrador cuando exista.
User.find_or_create_by!(email_address: "admin@rubipticos.com") do |user|
  user.password = "rubipticos"
end

# TODO: reemplazar por el SincronizadorDeCripticos (el enunciado pide que db:seed use el mismo sincronizador).
Criptico.find_or_create_by!(id: "cr-013") do |criptico|
  criptico.assign_attributes(
    version: "2026-10-19.1",
    enunciado: "Mi metido en el hogar da una prenda",
    enumeracion: 6,
    respuesta: "CAMISA",
    definiciones: [ "una prenda" ],
    indicadores: [ "metido en" ],
    materiales: [ "Mi", "el hogar" ],
    tipo: Tipo.find_by!(tipo: "contenedor"),
    dificultad: Dificultad.find_by!(dificultad: "medio"),
    ayuda: "El hogar es una palabra de cuatro letras. Partila al medio y meté MI.",
    explicacion: "MI dentro de CASA (el hogar): CA + MI + SA = CAMISA.",
    autor: "Cátedra"
  )
end
