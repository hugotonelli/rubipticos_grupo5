module Admin
  module SincronizacionesHelper
    ESTADOS = {
      "exitosa" => [ "Exitosa", "success" ],
      "sin_cambios" => [ "Sin cambios", "secondary" ],
      "fallida" => [ "Fallida", "danger" ]
    }.freeze

    # Etiqueta de color para el estado de una sincronización.
    def badge_de_estado(sincronizacion)
      texto, color = ESTADOS.fetch(sincronizacion.estado)
      tag.span(texto, class: "badge text-bg-#{color}")
    end
  end
end
