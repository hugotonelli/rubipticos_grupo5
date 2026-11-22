# Be sure to restart your server when you modify this file.

# Rails pluraliza en inglés: sin estas reglas "jugador" daría la tabla "jugadors",
# "sincronizacion" daría "sincronizacions" y "pista" se tomaría como plural latino ("pistum").
#
# IMPORTANTE: agregar la regla ANTES de generar un modelo nuevo, y comprobarla con
#   bin/rails runner 'p "jugador".pluralize, "jugadores".singularize'
#
# Se usa irregular palabra por palabra (y no una regla general tipo "consonante + es")
# porque una regla general rompería los nombres en inglés que genera Rails (users, sessions).
#
# Usa :en como locale porque `bin/rails g model` usa inglés por defecto y parece no poder cambiarse.
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.irregular "configuracion", "configuraciones"
  inflect.irregular "definicion", "definiciones"
  inflect.irregular "dificultad", "dificultades"
  inflect.irregular "indicador", "indicadores"
  inflect.irregular "jugador", "jugadores"
  inflect.irregular "material", "materiales"
  inflect.irregular "pista", "pistas"
  inflect.irregular "sincronizacion", "sincronizaciones"
end
