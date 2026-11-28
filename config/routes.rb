Rails.application.routes.draw do
  # Sitio público (jugadores, sin login).
  root "inicio#index"
  get "como-se-juega", to: "paginas#como_se_juega", as: :como_se_juega
  # El jugador actual (el de la cookie): elegir nombre.
  resource :jugador, only: %i[new create]
  # Jugar: elegir dificultad (new), «Jugar» (create) y la partida (show).
  resources :partidas, only: %i[new create show]

  # Login del backend (generado con bin/rails generate authentication).
  resource :session
  resources :passwords, param: :token

  # Backend de administración: controladores en app/controllers/admin/,
  # todos heredan de Admin::BaseController.
  namespace :admin do
    root "inicio#index"
    # Historial, «Sincronizar ahora» (create) e informe de cada sincronización.
    resources :sincronizaciones, only: %i[index create show]
    # Listado con filtros, detalle con estadísticas y activar/desactivar (update solo cambia `activo`).
    resources :cripticos, only: %i[index show update]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
