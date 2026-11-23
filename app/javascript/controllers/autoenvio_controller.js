import { Controller } from "@hotwired/stimulus"

// Envía el formulario apenas cambia un campo (se usa en los filtros del backend).
//   <form data-controller="autoenvio"> ... <select data-action="autoenvio#enviar">
export default class extends Controller {
  enviar() {
    this.element.requestSubmit()
  }
}
