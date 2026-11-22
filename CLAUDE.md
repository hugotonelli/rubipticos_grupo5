# Rubípticos — TFI TTPS Ruby 2026 (UNLP), grupo 5

Sitio para jugar crípticos (acertijos de palabras en español), en Ruby on Rails.
La especificación es el enunciado del TFI 2026 (Moodle). Ante cualquier duda, manda el enunciado.
El README tiene la instalación, el modelo de datos y las decisiones de diseño.

## Stack (no cambiar)

- Ruby 4.0.10 (`.ruby-version`), Rails 8.1, SQLite.
- Hotwire (Turbo + Stimulus) para la interactividad. **Prohibido React, Vue o cualquier framework de frontend aparte.**
- Bootstrap vía cssbundling (`yarn`). Levantar con `bin/dev`, no con `bin/rails server`.
- Login del backend: el generador de Rails 8 (ya generado). **No usar Devise.**
- Interfaz en español (`rails-i18n` + `config/locales/es.yml`) y responsive (celular y tablet).
- Antes de subir: `bin/rails test`, `bin/rubocop` y `bin/brakeman` tienen que pasar (los corre el CI).

## Convenciones del proyecto

- Modelos en castellano (`Criptico`, `Tipo`, `Dificultad`, `Jugador`, `Partida`, `Configuracion`).
  Rails pluraliza en inglés: agregar la regla en `config/initializers/inflections.rb` **antes** de
  generar un modelo nuevo y comprobarla con `bin/rails runner 'p "palabra".pluralize'`.
  Usar `inflect.irregular` por palabra; una regla general rompe `users` y `sessions`.
- Hora: `config.time_zone` es Buenos Aires. Para "hoy" usar siempre `Date.current` / `Time.current`,
  nunca `Date.today` ni `Time.now` (las rachas dependen de esto).
- `Tipo#nombre` y `Dificultad#nombre` son los identificadores de la API (`facil`, `doble_definicion`);
  para mostrar se usa `to_s` («Fácil», «Doble definición»).
- Crípticos: `id` numérico propio; el id de la API va en `id_fuente`.
- Configuración general: `Configuracion.actual` (una sola fila).
- Comparar textos (respuestas, enumeración, anagramas) siempre con `NormalizadorDeTexto.call`.
- Seeds idempotentes (`find_or_create_by!`).
- Commits en castellano, en tercera persona y que digan qué hacen ("Agrega...", "Corrige...").

## Reglas de arquitectura (son criterio de evaluación)

- **Lógica fuera de los controladores.** Reglas de negocio en modelos o en `app/services/`
  (clases Ruby comunes, convención `Clase.call(...)`). El controlador solo lee parámetros, llama
  al servicio y decide la respuesta (`render ..., status: :unprocessable_content` si falla la
  validación, `redirect_to ..., status: :see_other` después de borrar). Parámetros con `params.expect`.
- **Validar dos veces:** `validates` en el modelo **y** restricciones en la base (`null: false`,
  índices únicos, claves foráneas, check constraints).
- Convention over configuration: nombres, carpetas y rutas REST como espera Rails.
- Scaffold sí para los ABM del admin (revisando y recortando lo generado); **no** para el flujo
  de partida (escribirlo a mano).
- Controladores públicos: declaran `allow_unauthenticated_access`.
- Controladores del backend: en `app/controllers/admin/`, heredan de `Admin::BaseController`
  (layout `admin`). Por defecto solo entran administradores; si el editor de puntajes también
  puede usarlo, declarar `permitir_editor_de_puntajes`. Ocultar links no alcanza.

## Reglas de dominio que no se pueden romper

- **Jugador:** sin cuenta ni contraseña. Se identifica con su `token` en `cookies.signed`
  (con otro nombre de cookie que la del admin, que es `session_id`). Nada de puntos ni progreso
  en cookies o localStorage: todo vive en la base.
- Nombre de jugador: 3 a 20 caracteres, único sin distinguir mayúsculas, sin espacios al principio
  o al final; si está tomado, sugerir variante (`Pedrito_2`).
- **La respuesta correcta nunca viaja al navegador antes de resolver o rendirse.** Cada intento se
  valida en el servidor.
- **El tiempo oficial lo calcula el servidor** (`iniciada_at` / `finalizada_at`). El cronómetro de
  Stimulus es solo visual.
- Comparación de respuestas normalizada: sin tildes, sin mayúsculas, sin espacios ni signos.
  La Ñ se distingue de la N (`NormalizadorDeTexto`).
- Máximo 5 intentos y 4 pistas en orden fijo (tipo, definición, indicador y material, ayuda).
  Cada críptico se juega una sola vez por jugador.
- Puntaje: `base × tiempo × pistas × racha`, redondeado, mínimo 10 si resuelve, 0 si se rinde.
  Se guarda en la partida al resolverse; cambiar la configuración no recalcula partidas viejas.

## Sincronización del catálogo

- Lógica en un servicio (`SincronizadorDeCripticos`), nunca en el controlador.
- GET por HTTP a `Configuracion.actual.url_fuente`, timeout de 10 s. **Prohibido leer el JSON del disco.**
- Si falla la red o el JSON no parsea, no se toca nada y se informa.
- Si `version` coincide con la última sincronización exitosa: "Sin cambios".
- Identificar por `id` de la fuente (`id_fuente`): crear si no existe, actualizar si cambió.
  Inválidos se saltean y se informan con id y motivo. Los que ya no vienen se **desactivan**, no se borran.
- Registrar cada sincronización: fecha, admin, versión, creados, actualizados, desactivados, rechazados.
- `db:seed` usa el mismo sincronizador. `bin/rails db:setup` tiene que dejar el sistema jugable con un admin.
- En el JSON la clave es `material` (singular) y la enumeración viene como texto (`"(6)"`).
- Trampas conocidas: en `cryptics_with_errors.json` hay un `id` repetido; en el catálogo real,
  cr-021 (finales, MAR) tiene material «álbum, casa y amor»: hay que ignorar palabras de unión
  (y, e, o) al tomar iniciales o finales.
- API: `https://ecorrons.github.io/cryptics-api/v1/cryptics.json` (también `version.json` y
  `cryptics_with_errors.json`).

## Alcance

Grupo de 3: **sin extras** (no hace falta críptico del día, compartir resultado ni módulo de
estadísticas). El backend de administración y la tabla de posiciones **sí** son obligatorios.
El chatbot es opcional; alcanza una página de instrucciones (`Cómo se juega`).

## Forma de trabajo

- Una rama por tarea, PR a `main`, nadie trabaja directo sobre `main`.
- Commits chicos y claros. Todos los integrantes tienen que tener commits.
- Cada integrante tiene que poder explicar cualquier parte del código en el coloquio: preferir
  código simple y explicable a código ingenioso.
