// app/javascript/controllers/loading_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["spinner"]

  connect() {
    document.addEventListener("turbo:before-fetch-request", this.showSpinner.bind(this))
    document.addEventListener("turbo:before-fetch-response", this.hideSpinner.bind(this))
  }

  disconnect() {
    document.removeEventListener("turbo:before-fetch-request", this.showSpinner.bind(this))
    document.removeEventListener("turbo:before-fetch-response", this.hideSpinner.bind(this))
  }

  showSpinner() {
    this.spinnerTarget.classList.remove("hidden")
  }

  hideSpinner() {
    this.spinnerTarget.classList.add("hidden")
  }
}