// app/javascript/controllers/notifications_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["badge", "list"]
  static values = {
    count: Number
  }

  connect() {
    this.setupSubscription()
  }

  setupSubscription() {
    this.subscription = this.subscription || this.createSubscription()
  }

  createSubscription() {
    return this.application.consumer.subscriptions.create("NotificationsChannel", {
      controller: this,

      received(data) {
        // Handle incoming notification
        this.controller.handleNotification(data)
      }
    })
  }

  handleNotification(data) {
    // Update notification count
    this.countValue++
    this.updateBadge()

    // Prepend new notification to list if it exists
    if (this.hasListTarget) {
      this.listTarget.insertAdjacentHTML('afterbegin', data.html)
    }

    // Show toast notification
    this.showToast(data.message)
  }

  markAsRead(event) {
    event.preventDefault()
    const id = event.currentTarget.dataset.notificationId

    fetch(`/notifications/${id}/mark_as_read`, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector("[name='csrf-token']").content
      }
    }).then(response => {
      if (response.ok) {
        event.currentTarget.closest('.notification-item').classList.add('read')
        this.countValue--
        this.updateBadge()
      }
    })
  }

  markAllAsRead(event) {
    event.preventDefault()

    fetch('/notifications/mark_all_as_read', {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector("[name='csrf-token']").content
      }
    }).then(response => {
      if (response.ok) {
        this.listTarget.querySelectorAll('.notification-item').forEach(item => {
          item.classList.add('read')
        })
        this.countValue = 0
        this.updateBadge()
      }
    })
  }

  updateBadge() {
    if (this.hasBadgeTarget) {
      this.badgeTarget.textContent = this.countValue
      this.badgeTarget.classList.toggle('hidden', this.countValue === 0)
    }
  }

  showToast(message) {
    // You can implement your preferred toast notification here
    // For example, using a library like Toastify-js
    if (window.Toastify) {
      Toastify({
        text: message,
        duration: 3000,
        close: true,
        gravity: "top",
        position: "right",
        stopOnFocus: true
      }).showToast()
    }
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }
}