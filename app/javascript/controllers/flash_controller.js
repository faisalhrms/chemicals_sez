import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 5000 } }

  connect() {
    this.beforeCache = () => this.dismiss()
    document.addEventListener("turbo:before-cache", this.beforeCache)
    this.schedule()
  }

  schedule() {
    this.pause()
    if (!this.element.matches(":hover") && !this.element.contains(document.activeElement)) {
      this.timer = setTimeout(() => this.dismiss(), this.delayValue)
    }
  }

  pause() {
    clearTimeout(this.timer)
  }

  dismiss() {
    this.pause()
    this.element.remove()
  }

  disconnect() {
    this.pause()
    document.removeEventListener("turbo:before-cache", this.beforeCache)
  }
}
