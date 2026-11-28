module Admin
  module CripticosHelper
    HOST_CATEDRA = URI.parse(Configuracion::URL_CATEDRA).host

    # El origen es el host de la fuente; el de la API de la cátedra se muestra con su nombre.
    def nombre_de_origen(origen)
      origen == HOST_CATEDRA ? "API de la cátedra" : origen
    end

    def opciones_de_origen
      Criptico.distinct.order(:origen).pluck(:origen).map { |origen| [ nombre_de_origen(origen), origen ] }
    end

    def badge_de_activo(criptico)
      if criptico.activo?
        tag.span("Activo", class: "badge text-bg-success")
      else
        tag.span("Inactivo", class: "badge text-bg-secondary")
      end
    end

    # 75 => "1 min 15 s"; nil => "—".
    def duracion(segundos)
      return "—" if segundos.nil?

      minutos, resto = segundos.divmod(60)
      minutos.positive? ? "#{minutos} min #{resto} s" : "#{resto} s"
    end

    def porcentaje(valor)
      valor.nil? ? "—" : "#{valor} %"
    end

    # Botón que activa o desactiva el críptico (PATCH a update).
    def boton_activar_desactivar(criptico, clase: "btn btn-sm")
      activar = !criptico.activo?
      button_to activar ? "Activar" : "Desactivar",
                admin_criptico_path(criptico),
                method: :patch,
                params: { criptico: { activo: activar } },
                class: "#{clase} #{activar ? "btn-outline-success" : "btn-outline-secondary"}",
                form: { class: "d-inline" }
    end
  end
end
