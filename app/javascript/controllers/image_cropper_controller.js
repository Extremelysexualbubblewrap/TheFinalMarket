// app/javascript/controllers/image_cropper_controller.js
import { Controller } from "@hotwired/stimulus"
import Cropper from "cropperjs"

export default class extends Controller {
  static targets = ["modal", "image", "cropButton"]

  connect() {
    this.cropper = null
  }

  open(event) {
    const imageUrl = event.currentTarget.dataset.imageUrl
    this.imageTarget.src = imageUrl
    this.modalTarget.classList.remove("hidden")

    this.cropper = new Cropper(this.imageTarget, {
      aspectRatio: 1,
      viewMode: 1,
      dragMode: 'move',
      autoCropArea: 0.8,
      restore: false,
      guides: false,
      center: false,
      highlight: false,
      cropBoxMovable: false,
      cropBoxResizable: false,
      toggleDragModeOnDblclick: false,
    })
  }

  close() {
    this.modalTarget.classList.add("hidden")
    if (this.cropper) {
      this.cropper.destroy()
      this.cropper = null
    }
  }

  crop() {
    if (!this.cropper) return

    this.cropper.getCroppedCanvas({
      width: 1024,
      height: 1024,
      imageSmoothingQuality: 'high',
    }).toBlob((blob) => {
      // Here you would typically upload the blob to your server
      // For now, we'll just display it in a new window as a demo
      const url = URL.createObjectURL(blob)
      window.open(url)
      this.close()
    }, 'image/jpeg')
  }
}