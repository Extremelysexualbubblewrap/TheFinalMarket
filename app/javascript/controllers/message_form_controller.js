import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "submit"]
  
  connect() {
    this.typingTimeout = null
  }
  
  onKeydown(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.submit()
    }
  }
  
  onInput(event) {
    this.broadcastTyping()
  }
  
  openFilePicker() {
    this.fileInputTarget.click()
  }
  
  clear() {
    this.element.reset()
  }
  
  broadcastTyping() {
    clearTimeout(this.typingTimeout)
    
    if (!this.hasEmittedTyping) {
      this.stimulate("Conversation#typing")
      this.hasEmittedTyping = true
    }
    
    this.typingTimeout = setTimeout(() => {
      this.stimulate("Conversation#stopTyping")
      this.hasEmittedTyping = false
    }, 1000)
  }
}