# Simula que el navegador ya tiene la cookie firmada de un jugador (como sign_in_as para el admin).
module JugadorTestHelper
  def jugar_como(jugador)
    ActionDispatch::TestRequest.create.cookie_jar.tap do |cookie_jar|
      cookie_jar.signed[JugadorActual::COOKIE] = jugador.token
      cookies[JugadorActual::COOKIE.to_s] = cookie_jar[JugadorActual::COOKIE]
    end
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include JugadorTestHelper
end
