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
```

## Decisiones de diseño

- **Modelos en castellano** (`Criptico`, `Tipo`, `Dificultad`). Como Rails pluraliza en inglés,
  las reglas de plural están en `config/initializers/inflections.rb` y hay que agregarlas
  **antes** de generar cada modelo nuevo.
- **Crípticos**: `id` numérico propio; el identificador de la API de la cátedra se guarda en
  `id_fuente` (único). Así las demás tablas los referencian con la convención de Rails.
  Los que ya no vienen en la fuente se desactivan (`activo`), no se borran.
- **Tipo y dificultad** son tablas propias porque sus puntos y multiplicadores se editan desde
  el backend. Sus nombres son los mismos que usa la API (`facil`, `doble_definicion`, ...).
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
