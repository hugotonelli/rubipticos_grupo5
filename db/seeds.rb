# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Dificultad.create([
  { dificultad: "fácil", multiplicador: 1, tiempo: 60 },
  { dificultad: "medio", multiplicador: 2, tiempo: 180 },
  { dificultad: "avanzado", multiplicador: 3, tiempo: 300 },
])

Tipo.create([
  { tipo: "anagrama", puntos: 100, descripcion: "Reordenar las letras del material." },
  { tipo: "oculta", puntos: 100, descripcion: "La respuesta está escrita de corrido dentro del material." },
  { tipo: "charada", puntos: 100, descripcion: "Se pegan piezas una detrás de otra." },
  { tipo: "contenedor", puntos: 100, descripcion: "Una pieza va dentro de otra." },
  { tipo: "inversion", puntos: 100, descripcion: "El material se lee al revés." },
  { tipo: "supresion", puntos: 100, descripcion: "Se quita una letra del principio, del final o del medio." },
  { tipo: "homofono", puntos: 100, descripcion: "Una palabra que suena igual a otra. En castellano: h muda, b/v, s/c/z, ll/y." },
  { tipo: "doble_definicion", puntos: 100, descripcion: "Dos definiciones de la misma palabra. No hay indicador ni material." },
  { tipo: "iniciales", puntos: 100, descripcion: "Las primeras letras de palabras seguidas." },
  { tipo: "finales", puntos: 100, descripcion: "Las últimas letras de palabras seguidas." },
  { tipo: "sustitucion", puntos: 100, descripcion: "Se cambia una letra por otra." },
  { tipo: "simbolos", puntos: 100, descripcion: "Abreviaturas convencionales: números romanos, puntos cardinales, elementos químicos, notas musicales." },
  { tipo: "combinada", puntos: 100, descripcion: "Dos o más operaciones en el mismo enunciado." },
])

Criptico.create([
  {
    id: "cr-013",
    version: "2026-10-19.1",
    enunciado: "Mi metido en el hogar da una prenda",
    enumeracion: 6,
    respuesta: "CAMISA",
    definiciones: ["una prenda"],
    indicadores: ["metido en"],
    materiales: ["Mi", "el hogar"],
    tipo: Tipo.find_by(tipo: "contenedor"),
    dificultad: Dificultad.find_by(dificultad: "medio"),
    ayuda: "El hogar es una palabra de cuatro letras. Partila al medio y meté MI.",
    explicacion: "MI dentro de CASA (el hogar): CA + MI + SA = CAMISA.",
    autor: "Cátedra",
  }
])