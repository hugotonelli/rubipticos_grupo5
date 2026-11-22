Rails.application.routes.draw do
  # Sitio público (jugadores, sin login).
  root "inicio#index"
  get "como-se-juega", to: "paginas#como_se_juega", as: :como_se_juega

  # Login del backend (generado con bin/rails generate authentication).
  resource :session
  resources :passwords, param: :token

  # Backend de administración: controladores en app/controllers/admin/,
  # todos heredan de Admin::BaseController.
  namespace :admin do
    root "inicio#index"
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
