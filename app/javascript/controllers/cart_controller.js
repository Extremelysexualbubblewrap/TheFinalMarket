// app/javascript/controllers/cart_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["count", "total", "items"]
  static values = {
    updateUrl: String,
    removeUrl: String
  }

  connect() {
    this.updateCart()
  }

  async updateQuantity(event) {
    const itemId = event.target.dataset.itemId
    const quantity = event.target.value

    try {
      const response = await fetch(this.updateUrlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
        },
        body: JSON.stringify({ item_id: itemId, quantity: quantity })
      })

      if (response.ok) {
        // Turbo Stream will handle the update
      }
    } catch (error) {
      console.error("Cart update error:", error)
    }
  }

  async removeItem(event) {
    event.preventDefault()
    const itemId = event.target.dataset.itemId

    try {
      const response = await fetch(this.removeUrlValue.replace(":id", itemId), {
        method: "DELETE",
        headers: {
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
        }
      })

      if (response.ok) {
        // Turbo Stream will handle the removal
      }
    } catch (error) {
      console.error("Cart remove error:", error)
    }
  }

  updateCart() {
    if (this.hasCountTarget) {
      const itemCount = this.itemsTarget.children.length
      this.countTarget.textContent = itemCount
    }

    if (this.hasTotalTarget) {
      const total = Array.from(this.itemsTarget.children).reduce((sum, item) => {
        const price = parseFloat(item.dataset.price)
        const quantity = parseInt(item.dataset.quantity)
        return sum + (price * quantity)
      }, 0)
      this.totalTarget.textContent = total.toFixed(2)
    }
  }
}