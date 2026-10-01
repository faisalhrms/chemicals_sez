import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  clamp() {
    const value = this.element.valueAsNumber
    if (!Number.isFinite(value)) return

    if (value > 100) this.element.value = "100"
    if (value < 0) this.element.value = "0"
  }
}
