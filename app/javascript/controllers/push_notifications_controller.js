// app/javascript/controllers/push_notifications_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["prompt"]

  connect() {
    this.checkNotificationPermission()
  }

  checkNotificationPermission() {
    if (!('Notification' in window)) {
      this.hidePrompt()
      return
    }

    if (Notification.permission === 'default') {
      this.showPrompt()
    } else {
      this.hidePrompt()
    }
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

  async requestPermission() {
    try {
      const permission = await Notification.requestPermission()
      
      if (permission === 'granted') {
        await this.subscribeToPush()
        this.hidePrompt()
        this.showSuccess()
      } else {
        this.hidePrompt()
        this.showError('Notifications were not enabled')
      }
    } catch (error) {
      console.error('Error requesting notification permission:', error)
      this.showError('Could not enable notifications')
    }
  }

  async subscribeToPush() {
    if (!('serviceWorker' in navigator) || !('PushManager' in window)) {
      throw new Error('Push notifications not supported')
    }

    try {
      const registration = await navigator.serviceWorker.ready
      const subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: this.urlBase64ToUint8Array(window.vapidPublicKey)
      })

      // Send the subscription to your server
      await fetch('/push_subscriptions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ subscription: subscription })
      })
    } catch (error) {
      console.error('Error subscribing to push:', error)
      throw error
    }
  }

  close() {
    this.hidePrompt()
  }

  showSuccess() {
    const notification = document.createElement('div')
    notification.className = 'fixed bottom-4 right-4 bg-green-500 text-white px-6 py-3 rounded-lg shadow-lg transform transition-all duration-300'
    notification.textContent = 'Notifications enabled successfully!'
    document.body.appendChild(notification)
    setTimeout(() => notification.remove(), 3000)
  }

  showError(message) {
    const notification = document.createElement('div')
    notification.className = 'fixed bottom-4 right-4 bg-red-500 text-white px-6 py-3 rounded-lg shadow-lg transform transition-all duration-300'
    notification.textContent = message
    document.body.appendChild(notification)
    setTimeout(() => notification.remove(), 3000)
  }

  urlBase64ToUint8Array(base64String) {
    const padding = '='.repeat((4 - base64String.length % 4) % 4)
    const base64 = (base64String + padding)
      .replace(/\-/g, '+')
      .replace(/_/g, '/')

    const rawData = window.atob(base64)
    const outputArray = new Uint8Array(rawData.length)

    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i)
    }
    return outputArray
  }
}