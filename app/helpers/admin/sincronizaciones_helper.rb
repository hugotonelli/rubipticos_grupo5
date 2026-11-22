module Admin
  module SincronizacionesHelper
    ESTADOS = {
      "exitosa" => [ "Exitosa", "success" ],
      "sin_cambios" => [ "Sin cambios", "secondary" ],
      "fallida" => [ "Fallida", "danger" ]
    }.freeze

    # Cantidad => color con el que se resalta cuando es mayor que 0.
    CANTIDADES = {
      creados: "success",
      actualizados: "primary",
      desactivados: "warning",
      rechazados: "danger"
    }.freeze

    # Etiqueta de color para el estado de una sincronización.
    def badge_de_estado(sincronizacion)
      texto, color = ESTADOS.fetch(sincronizacion.estado)
      tag.span(texto, class: "badge text-bg-#{color}")
    end

    # Resumen corto para el historial: solo las cantidades que no son 0, o el motivo si falló.
    def resultado_de(sincronizacion)
      return tag.span(sincronizacion.mensaje, class: "small text-danger") if sincronizacion.fallida?

      cantidades = CANTIDADES.filter_map do |campo, color|
        cantidad = sincronizacion.public_send(campo)
        tag.span("#{cantidad} #{campo}", class: "badge rounded-pill text-bg-#{color} bg-opacity-75") if cantidad.positive?
      end
      return tag.span("—", class: "text-body-secondary") if cantidades.empty?

      safe_join(cantidades, " ")
    end

    # Color del número en el informe: gris si es 0, el color de la cantidad si no.
    def color_de_cantidad(campo, cantidad)
      cantidad.positive? ? "text-#{CANTIDADES.fetch(campo)}" : "text-body-secondary"
    end
  end
end
