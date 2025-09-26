// app/javascript/controllers/image_upload_controller.js
import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = ["input", "preview", "gallery", "template"]
  static values = {
    url: String,
    maxFiles: Number
  }

  connect() {
    this.initializeDragAndDrop()
  }

  initializeDragAndDrop() {
    this.sortable = new Sortable(this.galleryTarget, {
      animation: 150,
      ghostClass: "bg-spirit-light/50",
      onEnd: this.reorderImages.bind(this)
    });

    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
      this.element.addEventListener(eventName, this.preventDefaults, false)
    })

    ['dragenter', 'dragover'].forEach(eventName => {
      this.element.addEventListener(eventName, () => {
        this.element.classList.add('border-spirit-secondary', 'shadow-spirit')
      })
    })

    ['dragleave', 'drop'].forEach(eventName => {
      this.element.addEventListener(eventName, () => {
        this.element.classList.remove('border-spirit-secondary', 'shadow-spirit')
      })
    })

    this.element.addEventListener('drop', this.handleDrop.bind(this))
  }

  handleDrop(e) {
    const dt = e.dataTransfer
    const files = dt.files
    this.uploadFiles(files)
  }

  browse() {
    this.inputTarget.click()
  }

  // Handle file input change
  async handleFileSelect(event) {
    const files = event.target.files
    this.uploadFiles(files)
  }

  async uploadFiles(files) {
    if (this.galleryTarget.children.length + files.length > this.maxFilesValue) {
      this.showError(`Maximum ${this.maxFilesValue} images allowed`)
      return
    }

    Array.from(files).forEach(file => {
      if (!file.type.startsWith('image/')) {
        this.showError('Only image files are allowed')
        return
      }
      this.uploadFile(file)
    })
  }

  async uploadFile(file) {
    // Create preview immediately
    const previewId = this.createPreview(file)
    
    // Start upload with magical loading animation
    const upload = new DirectUpload(file, this.urlValue)
    
    try {
      await new Promise((resolve, reject) => {
        upload.create((error, blob) => {
          if (error) {
            reject(error)
          } else {
            resolve(blob)
          }
        })
      })
      
      // Replace preview with success state
      this.updatePreviewSuccess(previewId, file)
    } catch (error) {
      this.updatePreviewError(previewId)
      this.showError('Upload failed')
    }
  }

  createPreview(file) {
    const previewId = Date.now().toString()
    const template = this.templateTarget.innerHTML
      .replace(/PREVIEW_ID/g, previewId)
    
    this.galleryTarget.insertAdjacentHTML('beforeend', template)
    
    // Show loading state with spirit animation
    const preview = this.galleryTarget.querySelector(`[data-preview-id="${previewId}"]`)
    this.showLoadingState(preview)
    
    // Generate and show image preview
    const reader = new FileReader()
    reader.onload = (e) => {
      const img = preview.querySelector('img')
      img.src = e.target.result
    }
    reader.readAsDataURL(file)
    
    return previewId
  }

  showLoadingState(preview) {
    preview.classList.add('uploading')
    preview.style.animation = 'spirit-pulse 2s infinite'
  }

  updatePreviewSuccess(previewId, file) {
    const preview = this.galleryTarget.querySelector(`[data-preview-id="${previewId}"]`)
    preview.classList.remove('uploading')
    preview.classList.add('upload-success')
    preview.style.animation = ''
    
    // Add success animation
    preview.style.transform = 'scale(1.1)'
    preview.style.boxShadow = 'var(--spirit-glow)'
    setTimeout(() => {
      preview.style.transform = 'scale(1)'
    }, 300)
  }

  updatePreviewError(previewId) {
    const preview = this.galleryTarget.querySelector(`[data-preview-id="${previewId}"]`)
    preview.classList.remove('uploading')
    preview.classList.add('upload-error')
    preview.style.animation = ''
    
    // Add error animation
    preview.style.transform = 'scale(0.9)'
    setTimeout(() => {
      preview.remove()
    }, 1000)
  }

  removeImage(event) {
    const preview = event.target.closest('[data-preview-id]')
    
    // Add removal animation
    preview.style.transform = 'scale(0.9)'
    preview.style.opacity = '0'
    setTimeout(() => {
      preview.remove()
    }, 300)
  }

  async reorderImages() {
    const positions = {}
    this.galleryTarget.querySelectorAll('[data-preview-id]').forEach((element, index) => {
      positions[element.dataset.previewId] = index + 1
    })

    try {
      await post(this.data.get("reorderUrl"), {
        body: { positions }
      })
      this.showSuccessMessage("Images reordered successfully")
    } catch (error) {
      this.showErrorMessage("Failed to reorder images")
    }
  }

  preventDefaults(e) {
    e.preventDefault()
    e.stopPropagation()
  }

  showError(message) {
    const event = new CustomEvent('notification', {
      detail: { message, type: 'error' }
    })
    window.dispatchEvent(event)
  }
}