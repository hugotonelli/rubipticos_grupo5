# Rubípticos

Sitio para jugar crípticos (acertijos de palabras en español), hecho en Ruby on Rails.
Trabajo Final Integrador de TTPS opción Ruby 2026 (UNLP), grupo 5.

## Requisitos

| Herramienta | Versión | Para qué |
| --- | --- | --- |
| Ruby | 4.0.10 (ver `.ruby-version`) | Lenguaje |
| Bundler | 4.x | Gemas |
| Node.js | 22.12 o superior | Compilar el CSS (Bootstrap + Sass) |
| Yarn | 1.22 | Dependencias de JavaScript |
| SQLite | 3 | Base de datos |

Rails 8.1 se instala con `bundle install`.

## Cómo levantar el proyecto

### Linux y macOS

```sh
# 1. Ruby 4.0.10 (con rbenv; con asdf o mise es equivalente)
rbenv install 4.0.10

# 2. Dependencias
bundle install
yarn install

# 3. Base de datos: crea la base, carga el esquema y los datos iniciales (incluye el admin)
bin/rails db:setup

# 4. Servidor (usar bin/dev y no bin/rails server: bin/dev también compila el CSS)
bin/dev
```

Abrir <http://localhost:3000>.

### Windows

La forma recomendada es usar **WSL 2** (Ubuntu) y seguir los pasos de Linux dentro de WSL:

```powershell
wsl --install -d Ubuntu
```

Dentro de Ubuntu, instalar las dependencias de compilación antes de Ruby:

```sh
sudo apt update
sudo apt install -y git build-essential autoconf bison curl libssl-dev libyaml-dev libsqlite3-dev libreadline-dev zlib1g-dev libffi-dev
```

y después Node.js 22, Yarn (`npm install -g yarn`), rbenv y los pasos 1 a 4 de arriba.

### Actualizar después de un `git pull`

```sh
bundle install
yarn install
bin/rails db:migrate
```

Si cambian los datos iniciales, `bin/rails db:reset` borra la base local y la vuelve a crear con los seeds.

## Usuario administrador de prueba

| Email | Contraseña | Rol |
| --- | --- | --- |
| `admin@rubipticos.com` | `rubipticos` | Administrador |

El backend está en <http://localhost:3000/admin> (pide login).

## Comandos útiles

```sh
bin/rails test          # tests
bin/rubocop             # estilo (lo exige el CI)
bin/brakeman            # análisis de seguridad
bin/rails console       # probar modelos a mano
bin/rails routes        # ver las rutas
bin/rails cripticos:sincronizar  # sincronizar el catálogo desde la terminal (como el botón del backend)
```

## Modelo de datos

```
┌───────────────┐       ┌──────────────────────┐       ┌───────────────┐
│ tipos         │ 1   * │ cripticos            │ *   1 │ dificultades  │
├───────────────┤───────├──────────────────────┤───────├───────────────┤
│ nombre  único │       │ id_fuente     único  │       │ nombre  único │
│ puntos 10-1000│       │ enunciado, respuesta │       │ multiplicador │
│ descripcion   │       │ enumeracion          │       │   (0, 5]      │
└───────────────┘       │ definiciones (JSON)  │       │ tiempo (seg)  │
                        │ indicadores  (JSON)  │       └───────────────┘
                        │ materiales   (JSON)  │
                        │ ayuda, explicacion   │
                        │ autor, activo        │
                        └──────────┬───────────┘
                                   │ 1
                                   │ *
┌──────────────────────┐ 1    * ┌──┴───────────────────────────┐
│ jugadores            │────────│ partidas                     │
├──────────────────────┤        ├──────────────────────────────┤
│ nombre (3-20, único  │        │ estado: en_curso / resuelta /│
│   sin mayúsculas)    │        │   rendida                    │
│ token  único         │        │ iniciada_at, finalizada_at   │
│ bloqueado            │        │ intentos (0-5)               │
│ racha_actual         │        │ pistas_usadas (0-4)          │
│ mejor_racha          │        │ puntos                       │
│ ultimo_dia_jugado    │        │ UNIQUE(jugador, criptico)    │
└──────────────────────┘        └──────────────────────────────┘

users (backend): email único, rol (administrador / editor_puntajes), activo
configuraciones (una fila): url_fuente, texto_bienvenida
sincronizaciones: user, url, version, estado (exitosa / sin_cambios / fallida), mensaje,
                  creados, actualizados, desactivados, rechazados, detalle_rechazados (JSON)
```

### Validaciones

Se validan en **dos lugares**: en la base (migraciones) y en el modelo.

| Regla | Base de datos | Modelo |
| --- | --- | --- |
| Críptico: enunciado, respuesta, tipo y dificultad obligatorios | `null: false` + claves foráneas | `presence` + `belongs_to` |
| Críptico: id de la fuente único | índice único | `uniqueness` |
| Críptico: enumeración obligatoria, con la forma `(6)` o `(3,4)` | `null: false` + check | `presence` + `format` |
| Críptico: enumeración = largo de la respuesta sin tildes ni espacios | — | `validate` con `NormalizadorDeTexto` |
| Tipo y dificultad: solo los valores del enunciado, nombre único | check constraint + índice único | `inclusion` + `uniqueness` |
| Tipo: puntos enteros entre 10 y 1000 | check constraint | `numericality` |
| Dificultad: multiplicador mayor que 0 y hasta 5 | check constraint | `numericality` |
| Jugador: nombre de 3 a 20, único sin distinguir mayúsculas | check + índice único sobre `lower(nombre)` | `length` + `uniqueness(case_sensitive: false)` |
| Partida: un críptico por jugador | índice único | `uniqueness(scope:)` |
| Partida: hasta 5 intentos y 4 pistas | check constraints | `numericality` |
| Usuario: rol válido | check constraint | `enum ... validate: true` |

## Decisiones de diseño

- **Modelos en castellano** (`Criptico`, `Tipo`, `Dificultad`). Como Rails pluraliza en inglés,
  las reglas de plural están en `config/initializers/inflections.rb` y hay que agregarlas
  **antes** de generar cada modelo nuevo.
- **Crípticos**: `id` numérico propio; el identificador de la API de la cátedra se guarda en
  `id_fuente` (único). Así las demás tablas los referencian con la convención de Rails.
  Los que ya no vienen en la fuente se desactivan (`activo`), no se borran.
- **Sincronización del catálogo** (`SincronizadorDeCripticos`, en `app/services`): GET por HTTP con
  timeout de 10 s; si falla la red o el JSON, no toca nada y queda registrada como fallida. Si la
  versión **y la URL** son las de la última sincronización exitosa, informa «Sin cambios» (si se
  cambia la URL a un fork o a un servidor local con la misma versión, se vuelve a sincronizar, como
  sugirió la cátedra en el foro). Procesa todo en una transacción. Decisiones propias, porque el
  enunciado no las cubre:
  - Un **id repetido** dentro del mismo catálogo: se usa la primera aparición y se rechazan las
    siguientes (el enunciado pide que los demás se procesen igual). Pasa en
    `cryptics_with_errors.json` con `cr-101`.
  - Un **catálogo vacío** se trata como error: procesarlo desactivaría todos los crípticos.
  - Sigue hasta 3 **redirecciones** (por ejemplo, si se configura la URL con `http://`).
  - La **enumeración** se guarda como texto, igual que en la API (`"(6)"`, o `"(3,4)"` si la
    respuesta tiene varias palabras), y se valida que la suma coincida con el largo de la respuesta.
  - **Origen** de un críptico: el host de la URL desde la que se sincronizó (la API de la cátedra,
    un fork o un servidor local), como respondió la cátedra en el foro. Si el mismo id llega
    después desde otra URL, se actualiza y su origen pasa a ser el nuevo.
  - Un críptico **desactivado por el sincronizador** (porque ya no venía) se reactiva si vuelve a
    aparecer; uno desactivado por un administrador queda desactivado.
  - En iniciales y finales se ignoran la puntuación y las palabras de unión (y, e, o, u, ni): en el
    catálogo real, cr-021 tiene material «álbum, casa y amor» y respuesta MAR.
  - `db:seed` sincroniza con la API, así que `db:setup` necesita conexión a internet.
- **Estadísticas de cada críptico** (backend): *veces jugado* cuenta todas las partidas;
  *porcentaje resuelto* es resueltas sobre terminadas (resueltas + rendidas), sin contar las que
  siguen en curso; *tiempo promedio* es el de las resueltas. Se calculan con consultas agrupadas
  (`Partida.estadisticas_por_criptico`), no una por críptico.
- **Activar o desactivar a mano** un críptico es decisión del administrador: el sincronizador no
  lo reactiva aunque vuelva a venir en la fuente.
- **Tipo y dificultad** son tablas propias porque sus puntos y multiplicadores se editan desde
  el backend. Su `nombre` es el identificador que usa la API (`facil`, `doble_definicion`, ...)
  y `to_s` devuelve el nombre para mostrar («Fácil», «Doble definición»).
- **Configuración**: una sola fila (`Configuracion.actual`). Guarda la URL **completa** del
  catálogo y no solo la base, para poder apuntar también a `cryptics_with_errors.json`.
- **Jugadores**: sin cuenta; los identifica un token (`has_secure_token`) que va en una cookie
  firmada. La racha se guarda en el jugador (`racha_actual`, `mejor_racha`, `ultimo_dia_jugado`)
  y `racha_vigente` la da por cortada si no jugó ayer ni hoy.
- **Jugador actual**: el concern `JugadorActual` (incluido en `ApplicationController`) lee el token
  de la cookie firmada `jugador_token` y da `jugador_actual` en controladores y vistas;
  `before_action :requerir_jugador` manda a elegir nombre si todavía no tiene. Un jugador
  **bloqueado** (nombre ofensivo) no puede seguir jugando: tiene que crear un jugador nuevo, como
  sugirió la cátedra. Si el nombre está
  tomado, `SugeridorDeNombre` propone una variante (`Pedrito_2`).
- **Empezar a jugar** (`IniciadorDePartida`): el críptico se asigna al azar recién al apretar
  «Jugar» (entre los activos de esa dificultad que el jugador no jugó), así no se guarda nada en el
  navegador mientras elige. Un jugador tiene como máximo una partida en curso (validación + índice
  único parcial): si cerró la pestaña, al volver a «Jugar» retoma esa.
- **Partidas**: el tiempo oficial es `finalizada_at - iniciada_at`, medido en el servidor.
  Los puntos se guardan al resolver, así un cambio de configuración no recalcula partidas viejas.
- **Validaciones en dos niveles**: en el modelo (`validates`) y en la base (`null: false`,
  índices únicos, claves foráneas y check constraints).
- **Lógica de negocio fuera de los controladores**: en los modelos y en servicios de
  `app/services` con la convención `Clase.call(...)`. Por ejemplo, `NormalizadorDeTexto`
  (sin tildes, mayúsculas, espacios ni signos; distingue la Ñ de la N).
- **Backend**: login con el generador de autenticación de Rails 8. Dos roles en `User`
  (`administrador` y `editor_puntajes`). Todos los controladores de `/admin` heredan de
  `Admin::BaseController`, que exige login y por defecto solo deja pasar administradores;
  los que también puede usar el editor lo declaran con `permitir_editor_de_puntajes`.
- **Fechas**: zona horaria de Buenos Aires; para "hoy" se usa siempre `Date.current`.
- **Interfaz** en español (`rails-i18n` y `config/locales/es.yml`), con Bootstrap y responsive.

## Forma de trabajo

Una rama por tarea y pull request a `main` (nadie trabaja directo sobre `main`).
El CI de GitHub corre tests, rubocop y los escaneos de seguridad en cada PR.
