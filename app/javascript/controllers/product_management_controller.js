// app/javascript/controllers/product_management_controller.js
import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"
import { post } from "@rails/request.js"

export default class extends Controller {
  static targets = [ "list", "product", "batchActions", "selectAll" ]
  static values = {
    reorderUrl: String
  }

  connect() {
    this.initializeSortable()
    this.updateBatchActionsVisibility()
  }

  initializeSortable() {
    this.sortable = new Sortable(this.listTarget, {
      animation: 150,
      handle: ".drag-handle",
      ghostClass: "bg-spirit-light/50",
      onEnd: this.updateOrder.bind(this)
    })
  }

  async updateOrder(event) {
    const positions = {}
    this.productTargets.forEach((product, index) => {
      positions[product.dataset.productId] = index + 1
    })

    // Add magical animation to the moved item
    event.item.classList.add('scale-105', 'shadow-spirit')
    setTimeout(() => {
      event.item.classList.remove('scale-105', 'shadow-spirit')
    }, 500)

    try {
      await post(this.reorderUrlValue, {
        body: { positions: positions, operation: 'reorder' }
      })
      this.showSuccessMessage("Products reordered successfully")
    } catch (error) {
      this.showErrorMessage("Failed to reorder products")
    }
  }

  toggleSelection(event) {
    const checkbox = event.target
    const productElement = checkbox.closest('[data-product-management-target="product"]')
    
    if (checkbox.checked) {
      productElement.classList.add('bg-spirit-light/30')
    } else {
      productElement.classList.remove('bg-spirit-light/30')
    }
    
    this.updateBatchActionsVisibility()
  }

  toggleAllSelection(event) {
    const checked = event.target.checked
    this.productTargets.forEach(product => {
      const checkbox = product.querySelector('input[type="checkbox"]')
      checkbox.checked = checked
      if (checked) {
        product.classList.add('bg-spirit-light/30')
      } else {
        product.classList.remove('bg-spirit-light/30')
      }
    })
    
    this.updateBatchActionsVisibility()
  }

  updateBatchActionsVisibility() {
    const selectedCount = this.getSelectedProducts().length
    this.batchActionsTarget.classList.toggle('hidden', selectedCount === 0)
    
    // Update selected count
    const countElement = this.batchActionsTarget.querySelector('.selected-count')
    if (countElement) {
      countElement.textContent = selectedCount
    }
  }

  getSelectedProducts() {
    return this.productTargets.filter(product => {
      return product.querySelector('input[type="checkbox"]').checked
    })
  }

  async updatePrices(event) {
    event.preventDefault()
    const adjustment = prompt("Enter adjustment amount:")
    const type = confirm("Press OK for percentage adjustment (%), Cancel for fixed amount") ? "percentage" : "fixed"
    
    if (!adjustment) return
    
    const productIds = this.getSelectedProducts().map(p => p.dataset.productId)
    
    try {
      await post(this.reorderUrlValue, {
        body: {
          product_ids: productIds,
          adjustment: adjustment,
          adjustment_type: type,
          operation: 'update_prices'
        }
      })
      this.showSuccessMessage("Prices updated successfully")
      location.reload()
    } catch (error) {
      this.showErrorMessage("Failed to update prices")
    }
  }

  async updateStock(event) {
    event.preventDefault()
    const adjustment = prompt("Enter stock adjustment (positive or negative number):")
    if (!adjustment) return
    
    const productIds = this.getSelectedProducts().map(p => p.dataset.productId)
    
    try {
      await post(this.reorderUrlValue, {
        body: {
          product_ids: productIds,
          adjustment: adjustment,
          operation: 'update_stock'
        }
      })
      this.showSuccessMessage("Stock updated successfully")
      location.reload()
    } catch (error) {
      this.showErrorMessage("Failed to update stock")
    }
  }

  async archiveProducts(event) {
    event.preventDefault()
    if (!confirm("Are you sure you want to archive the selected products?")) return
    
    const productIds = this.getSelectedProducts().map(p => p.dataset.productId)
    
    try {
      await post(this.reorderUrlValue, {
        body: {
          product_ids: productIds,
          operation: 'archive'
        }
      })
      this.showSuccessMessage("Products archived successfully")
      location.reload()
    } catch (error) {
      this.showErrorMessage("Failed to archive products")
    }
  }

  async assignCategory(event) {
    event.preventDefault()
    const categoryId = prompt("Enter category ID:")
    if (!categoryId) return

    const productIds = this.getSelectedProducts().map(p => p.dataset.productId)

    try {
      await post(this.reorderUrlValue, {
        body: {
          product_ids: productIds,
          category_id: categoryId,
          operation: 'assign_category'
        }
      })
      this.showSuccessMessage("Category assigned successfully")
      location.reload()
    } catch (error) {
      this.showErrorMessage("Failed to assign category")
    }
  }

  showSuccessMessage(message) {
    const event = new CustomEvent('notification', {
      detail: { message, type: 'success' }
    })
    window.dispatchEvent(event)
  }

  showErrorMessage(message) {
    const event = new CustomEvent('notification', {
      detail: { message, type: 'error' }
    })
    window.dispatchEvent(event)
  }
}