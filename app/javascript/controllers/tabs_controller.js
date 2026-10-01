import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    const requestedTab = window.location.hash.replace("#", "")
    const requestedIndex = this.tabTargets.findIndex((tab) => tab.dataset.tabId === requestedTab)
    const defaultIndex = this.tabTargets.findIndex((tab) => tab.dataset.active === "true")

    this.activate(requestedIndex >= 0 ? requestedIndex : (defaultIndex >= 0 ? defaultIndex : 0), false)
  }

  show(event) {
    this.activate(Number(event.currentTarget.dataset.index), true)
  }

  activate(index, updateUrl) {
    this.tabTargets.forEach((tab, tabIndex) => {
      const active = tabIndex === index
      tab.classList.toggle("portal-tab-active", active)
      tab.setAttribute("aria-selected", active ? "true" : "false")
      tab.setAttribute("tabindex", active ? "0" : "-1")
    })

    this.panelTargets.forEach((panel, panelIndex) => {
      panel.classList.toggle("hidden", panelIndex !== index)
    })

    if (updateUrl) {
      const tabId = this.tabTargets[index]?.dataset.tabId
      if (tabId) history.replaceState(null, "", `#${tabId}`)
    }
  }
}
