// app/javascript/controllers/pwa_install_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["prompt"]

  connect() {
    this.deferredPrompt = null
    
    window.addEventListener('beforeinstallprompt', (e) => {
      // Prevent Chrome 67 and earlier from automatically showing the prompt
      e.preventDefault()
      // Stash the event so it can be triggered later
      this.deferredPrompt = e
      // Show the install prompt
      this.showPrompt()
    })

    // Hide the prompt if the PWA is already installed
    window.addEventListener('appinstalled', () => {
      this.hidePrompt()
      this.deferredPrompt = null
    })
  }

  showPrompt() {
    const prompt = this.element
    prompt.classList.remove('translate-y-full', 'opacity-0')
    prompt.classList.add('translate-y-0', 'opacity-100')
  }

  hidePrompt() {
    const prompt = this.element
    prompt.classList.add('translate-y-full', 'opacity-0')
    prompt.classList.remove('translate-y-0', 'opacity-100')
  }

  async install() {
    if (!this.deferredPrompt) return

    // Show the install prompt
    this.deferredPrompt.prompt()

    // Wait for the user to respond to the prompt
    const { outcome } = await this.deferredPrompt.userChoice
    
    // Clear the deferredPrompt since it can't be used again
    this.deferredPrompt = null

    // Hide the prompt regardless of outcome
    this.hidePrompt()

    // Track the installation attempt
    this.trackInstallation(outcome)
  }

  close() {
    this.hidePrompt()
  }

  trackInstallation(outcome) {
    if (typeof gtag === 'function') {
      gtag('event', 'pwa_install_attempt', {
        event_category: 'PWA',
        event_label: outcome
      })
    }
  }
}