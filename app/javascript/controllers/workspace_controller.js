import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.update()
  }

  update() {
    const selected = this.element.querySelector('input[name="workspace"]:checked')
    if (!selected) return

    const label = selected.value === "authority" ? "Authority" : "Developer"
    const text = `Sign in as ${label}`
    if (this.buttonTarget instanceof HTMLInputElement) {
      this.buttonTarget.value = text
    } else {
      this.buttonTarget.textContent = text
    }
  }
}
