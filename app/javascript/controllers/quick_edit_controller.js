// app/javascript/controllers/quick_edit_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "form"]

  toggle() {
    if (this.displayTarget.classList.contains("hidden")) {
      // Show edit form with magical animation
      this.formTarget.classList.remove("hidden")
      this.formTarget.style.opacity = "0"
      this.formTarget.style.transform = "scale(0.95)"
      
      requestAnimationFrame(() => {
        this.formTarget.style.transition = "all 0.3s ease"
        this.formTarget.style.opacity = "1"
        this.formTarget.style.transform = "scale(1)"
      })
      
      this.displayTarget.classList.add("hidden")
      
      // Focus the first input
      const input = this.formTarget.querySelector("input, textarea, select")
      if (input) input.focus()
      
      // Add spirit glow effect
      this.formTarget.classList.add("shadow-spirit")
    } else {
      // Hide edit form with fade-out animation
      this.formTarget.style.transition = "all 0.3s ease"
      this.formTarget.style.opacity = "0"
      this.formTarget.style.transform = "scale(0.95)"
      
      setTimeout(() => {
        this.formTarget.classList.add("hidden")
        this.displayTarget.classList.remove("hidden")
        
        // Add highlight animation to the display
        this.displayTarget.style.opacity = "0"
        this.displayTarget.style.transform = "scale(0.95)"
        
        requestAnimationFrame(() => {
          this.displayTarget.style.transition = "all 0.3s ease"
          this.displayTarget.style.opacity = "1"
          this.displayTarget.style.transform = "scale(1)"
        })
      }, 300)
    }
  }

  cancel(event) {
    event.preventDefault()
    this.toggle()
  }

  // Add spirit effects on hover
  connect() {
    this.displayTarget.addEventListener("mouseenter", () => {
      if (!this.displayTarget.classList.contains("hidden")) {
        this.displayTarget.classList.add("shadow-spirit", "scale-102")
      }
    })

    this.displayTarget.addEventListener("mouseleave", () => {
      this.displayTarget.classList.remove("shadow-spirit", "scale-102")
    })
  }
}