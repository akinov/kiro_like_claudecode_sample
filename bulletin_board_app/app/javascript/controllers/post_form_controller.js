import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "counter"]
  
  connect() {
    this.updateCounter()
  }
  
  updateCounter() {
    const remaining = 1000 - this.contentTarget.value.length
    this.counterTarget.textContent = `残り${remaining}文字`
    
    if (remaining < 0) {
      this.counterTarget.classList.add("text-red-500")
    } else {
      this.counterTarget.classList.remove("text-red-500")
    }
  }
}