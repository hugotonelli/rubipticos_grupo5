# Páginas estáticas del sitio público.
class PaginasController < ApplicationController
  allow_unauthenticated_access

  # Instrucciones de juego (el enunciado permite esto en lugar del chatbot).
  def como_se_juega
  end
end
