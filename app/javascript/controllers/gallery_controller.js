import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["thumbnail", "mainImage"]
  static values = {
    url: String,
    currentIndex: { type: Number, default: 0 }
  }

  connect() {
    if (this.hasThumbnailTarget) {
      this.initializeSortable()
      this.initializeSwipeEvents()
      this.initializeKeyboardEvents()
    }
  }

  initializeSortable() {
    Sortable.create(this.element, {
      animation: 150,
      onEnd: this.updatePositions.bind(this)
    })
  }

  initializeSwipeEvents() {
    this.element.addEventListener('swipeLeft', this.nextImage.bind(this))
    this.element.addEventListener('swipeRight', this.previousImage.bind(this))
  }

  initializeKeyboardEvents() {
    this.handleKeyDown = this.handleKeyDown.bind(this)
    document.addEventListener('keydown', this.handleKeyDown)
  }

  disconnect() {
    document.removeEventListener('keydown', this.handleKeyDown)
  }

  handleKeyDown(event) {
    // Only handle keyboard events when gallery is visible in viewport
    if (!this.element.getBoundingClientRect().top < window.innerHeight) return

    switch(event.key) {
      case 'ArrowLeft':
        event.preventDefault()
        this.previousImage()
        break
      case 'ArrowRight':
        event.preventDefault()
        this.nextImage()
        break
      case 'Home':
        event.preventDefault()
        this.showFirstImage()
        break
      case 'End':
        event.preventDefault()
        this.showLastImage()
        break
    }
  }

  async updatePositions(event) {
    const id = event.item.dataset.id
    const position = event.newIndex + 1

    try {
      const response = await fetch(this.urlValue, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector("[name='csrf-token']").content
        },
        body: JSON.stringify({ position })
      })

      if (!response.ok) throw new Error('Failed to update position')
    } catch (error) {
      console.error('Error updating position:', error)
      // Optionally revert the sort
      this.element.dispatchEvent(new CustomEvent('sortable:error'))
    }
  }

  showImage(event) {
    const imageUrl = event.currentTarget.dataset.imageUrl
    const thumbnail = event.currentTarget
    const index = this.thumbnailTargets.indexOf(thumbnail)
    
    this.currentIndexValue = index
    this.updateGallery(imageUrl)
  }

  nextImage(event) {
    event?.preventDefault()
    const nextIndex = this.currentIndexValue + 1
    if (nextIndex < this.thumbnailTargets.length) {
      this.currentIndexValue = nextIndex
      const nextThumb = this.thumbnailTargets[nextIndex]
      this.updateGallery(nextThumb.dataset.imageUrl)
    }
  }

  previousImage(event) {
    event?.preventDefault()
    const prevIndex = this.currentIndexValue - 1
    if (prevIndex >= 0) {
      this.currentIndexValue = prevIndex
      const prevThumb = this.thumbnailTargets[prevIndex]
      this.updateGallery(prevThumb.dataset.imageUrl)
    }
  }

  showFirstImage(event) {
    event?.preventDefault()
    if (this.thumbnailTargets.length > 0) {
      this.currentIndexValue = 0
      const firstThumb = this.thumbnailTargets[0]
      this.updateGallery(firstThumb.dataset.imageUrl)
    }
  }

  showLastImage(event) {
    event?.preventDefault()
    const lastIndex = this.thumbnailTargets.length - 1
    if (lastIndex >= 0) {
      this.currentIndexValue = lastIndex
      const lastThumb = this.thumbnailTargets[lastIndex]
      this.updateGallery(lastThumb.dataset.imageUrl)
    }
  }

  updateGallery(imageUrl) {
    // Update main image with transition
    if (this.hasMainImageTarget) {
      this.mainImageTarget.classList.remove('opacity-100')
      this.mainImageTarget.classList.add('opacity-0')
      
      setTimeout(() => {
        this.mainImageTarget.src = imageUrl
        this.mainImageTarget.classList.remove('opacity-0')
        this.mainImageTarget.classList.add('opacity-100')
      }, 150)
    }

    // Update thumbnail active states
    this.thumbnailTargets.forEach((thumb, index) => {
      if (index === this.currentIndexValue) {
        thumb.classList.remove('border-transparent')
        thumb.classList.add('border-primary')
      } else {
        thumb.classList.remove('border-primary')
        thumb.classList.add('border-transparent')
      }
    })
  }
}