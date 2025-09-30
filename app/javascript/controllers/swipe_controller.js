import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    threshold: { type: Number, default: 50 }, // minimum distance for swipe
    restraint: { type: Number, default: 100 }, // maximum perpendicular distance
    allowedTime: { type: Number, default: 300 } // maximum time for swipe
  }

  connect() {
    this.bindSwipeEvents()
  }

  disconnect() {
    this.unbindSwipeEvents()
  }

  bindSwipeEvents() {
    this.handleTouchStart = this.handleTouchStart.bind(this)
    this.handleTouchMove = this.handleTouchMove.bind(this)
    this.handleTouchEnd = this.handleTouchEnd.bind(this)

    this.element.addEventListener('touchstart', this.handleTouchStart, false)
    this.element.addEventListener('touchmove', this.handleTouchMove, false)
    this.element.addEventListener('touchend', this.handleTouchEnd, false)
  }

  unbindSwipeEvents() {
    this.element.removeEventListener('touchstart', this.handleTouchStart)
    this.element.removeEventListener('touchmove', this.handleTouchMove)
    this.element.removeEventListener('touchend', this.handleTouchEnd)
  }

  handleTouchStart(e) {
    const firstTouch = e.touches[0]
    this.swipeStart = { x: firstTouch.clientX, y: firstTouch.clientY }
    this.swipeStartTime = Date.now()
  }

  handleTouchMove(e) {
    if (!this.swipeStart) return

    this.swipeEnd = {
      x: e.touches[0].clientX,
      y: e.touches[0].clientY
    }

    // Prevent vertical scrolling when swiping horizontally
    const deltaX = Math.abs(this.swipeEnd.x - this.swipeStart.x)
    const deltaY = Math.abs(this.swipeEnd.y - this.swipeStart.y)
    
    if (deltaX > deltaY && deltaX > 30) {
      e.preventDefault()
    }
  }

  handleTouchEnd() {
    if (!this.swipeStart || !this.swipeEnd) return

    const deltaX = this.swipeEnd.x - this.swipeStart.x
    const deltaY = this.swipeEnd.y - this.swipeStart.y
    const elapsedTime = Date.now() - this.swipeStartTime

    if (elapsedTime <= this.allowedTimeValue) {
      // horizontal swipe
      if (Math.abs(deltaX) >= this.thresholdValue && 
          Math.abs(deltaY) <= this.restraintValue) {
        if (deltaX > 0) {
          this.dispatch('swipeRight')
        } else {
          this.dispatch('swipeLeft')
        }
      }
      // vertical swipe
      else if (Math.abs(deltaY) >= this.thresholdValue && 
               Math.abs(deltaX) <= this.restraintValue) {
        if (deltaY > 0) {
          this.dispatch('swipeDown')
        } else {
          this.dispatch('swipeUp')
        }
      }
    }

    // Reset values
    this.swipeStart = null
    this.swipeEnd = null
  }

  dispatch(eventName) {
    const event = new CustomEvent(eventName, { 
      bubbles: true, 
      cancelable: true,
      detail: { 
        startX: this.swipeStart.x,
        startY: this.swipeStart.y,
        endX: this.swipeEnd.x,
        endY: this.swipeEnd.y
      }
    })
    this.element.dispatchEvent(event)
  }
}