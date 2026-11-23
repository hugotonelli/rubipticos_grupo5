namespace :cripticos do
  desc "Sincroniza el catálogo de crípticos desde la fuente configurada (como el botón del backend)"
  task sincronizar: :environment do
    # El enunciado pide registrar qué admin hizo cada sincronización: se usa el primer administrador activo.
    admin = User.administrador.activos.order(:id).first
    abort "No hay ningún administrador activo. Corré bin/rails db:seed para crear el de prueba." if admin.nil?

    sincronizacion = SincronizadorDeCripticos.call(usuario: admin)
    puts "Sincronización (#{sincronizacion.url}): #{sincronizacion.resumen}"
    sincronizacion.detalle_rechazados.each do |rechazo|
      puts "  rechazado #{rechazo["id"]}: #{rechazo["motivo"]}"
    end
  end
end
