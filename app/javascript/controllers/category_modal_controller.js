// app/javascript/controllers/category_modal_controller.js
import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

export default class extends Controller {
  static targets = ["modal", "search", "category"]

  connect() {
    // Add fade-in animation
    this.element.classList.add('animate-fade-in')
    document.body.classList.add('overflow-hidden')
  }

  disconnect() {
    document.body.classList.remove('overflow-hidden')
  }

  open() {
    this.modalTarget.classList.remove('hidden')
    this.searchTarget.focus()

    // Add entrance animation to categories
    this.categoryTargets.forEach((category, index) => {
      category.style.opacity = '0'
      category.style.transform = 'translateY(20px)'
      setTimeout(() => {
        category.style.transition = 'all 0.5s ease'
        category.style.opacity = '1'
        category.style.transform = 'translateY(0)'
      }, index * 50)
    })
  }

  close(event) {
    if (event) {
      event.preventDefault()
    }

    // Add exit animation
    this.modalTarget.classList.add('animate-fade-out')
    setTimeout(() => {
      this.modalTarget.classList.add('hidden')
      this.modalTarget.classList.remove('animate-fade-out')
    }, 300)
  }

  filterCategories() {
    const searchTerm = this.searchTarget.value.toLowerCase()
    
    this.categoryTargets.forEach(category => {
      const categoryName = category.dataset.categoryName
      const matches = categoryName.includes(searchTerm)
      
      if (matches) {
        category.classList.remove('hidden')
        // Add magical reveal animation
        category.style.opacity = '0'
        category.style.transform = 'scale(0.95)'
        setTimeout(() => {
          category.style.transition = 'all 0.3s ease'
          category.style.opacity = '1'
          category.style.transform = 'scale(1)'
        }, 50)
      } else {
        // Add magical hide animation
        category.style.transition = 'all 0.3s ease'
        category.style.opacity = '0'
        category.style.transform = 'scale(0.95)'
        setTimeout(() => {
          category.classList.add('hidden')
        }, 300)
      }
    })
  }

  async selectCategory(event) {
    const categoryId = event.currentTarget.dataset.categoryId
    const productIds = this.getSelectedProductIds()

    // Add selection animation
    event.currentTarget.classList.add('scale-95', 'shadow-spirit')
    setTimeout(() => {
      event.currentTarget.classList.remove('scale-95')
    }, 200)

    try {
      await post(this.data.get("updateUrl"), {
        body: {
          product_ids: productIds,
          category_id: categoryId,
          operation: 'assign_category'
        }
      })
      
      this.showSuccessMessage("Category assigned successfully")
      this.close()
      location.reload()
    } catch (error) {
      this.showErrorMessage("Failed to assign category")
    }
  }

  getSelectedProductIds() {
    return Array.from(document.querySelectorAll('[data-product-management-target="product"] input[type="checkbox"]:checked'))
      .map(checkbox => checkbox.closest('[data-product-id]').dataset.productId)
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