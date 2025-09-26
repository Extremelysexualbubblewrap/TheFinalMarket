// app/javascript/controllers/search_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]
  static values = {
    url: String,
    minLength: { type: Number, default: 2 }
  }

  search() {
    clearTimeout(this.timeout)
    const query = this.inputTarget.value

    if (query.length < this.minLengthValue) {
      this.resultsTarget.innerHTML = ""
      return
    }

    this.timeout = setTimeout(() => {
      this.performSearch(query)
    }, 300)
  }

  async performSearch(query) {
    const url = new URL(this.urlValue)
    url.searchParams.set("query", query)

    try {
      const response = await fetch(url)
      if (response.ok) {
        const html = await response.text()
        this.resultsTarget.innerHTML = html
      }
    } catch (error) {
      console.error("Search error:", error)
    }
  }
}