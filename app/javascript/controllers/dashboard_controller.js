// app/javascript/controllers/dashboard_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "statValue"]

  connect() {
    // Animate stats on load
    this.animateStats()
    
    // Add hover effects to cards
    this.addCardEffects()
  }

  animateStats() {
    this.statValueTargets.forEach(stat => {
      const finalValue = parseFloat(stat.textContent)
      this.animateValue(stat, 0, finalValue, 1500)
    })
  }

  animateValue(element, start, end, duration) {
    const startTimestamp = performance.now()
    
    const animate = (currentTimestamp) => {
      const elapsed = currentTimestamp - startTimestamp
      const progress = Math.min(elapsed / duration, 1)
      
      // Easing function for smooth animation
      const easing = t => t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t
      
      const currentValue = start + (end - start) * easing(progress)
      element.textContent = this.formatValue(currentValue, end)
      
      if (progress < 1) {
        requestAnimationFrame(animate)
      }
    }
    
    requestAnimationFrame(animate)
  }

  addCardEffects() {
    this.cardTargets.forEach(card => {
      card.addEventListener('mousemove', e => this.handleCardHover(e, card))
      card.addEventListener('mouseleave', () => this.resetCard(card))
    })
  }

  handleCardHover(e, card) {
    const rect = card.getBoundingClientRect()
    const x = e.clientX - rect.left
    const y = e.clientY - rect.top
    
    const centerX = rect.width / 2
    const centerY = rect.height / 2
    
    const rotateX = (y - centerY) / 20
    const rotateY = (centerX - x) / 20
    
    card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale3d(1.02, 1.02, 1.02)`
  }

  resetCard(card) {
    card.style.transform = 'perspective(1000px) rotateX(0) rotateY(0) scale3d(1, 1, 1)'
  }

  formatValue(value, finalValue) {
    // Format as currency if the final value has decimal points
    if (String(finalValue).includes('.')) {
      return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD'
      }).format(value)
    }
    // Otherwise format as integer
    return Math.round(value).toString()
  }
}