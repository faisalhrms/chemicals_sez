import { Turbo } from "@hotwired/turbo-rails"

let activeDialog = null

Turbo.config.forms.confirm = (message, form, submitter) => {
  // A second action cannot replace a confirmation already awaiting a decision.
  if (activeDialog) return Promise.resolve(false)

  return new Promise((resolve) => {
    const previousFocus = document.activeElement
    const action = submitter?.dataset.confirmLabel || form?.dataset.confirmLabel ||
      (submitter?.tagName === "INPUT" ? submitter.value : submitter?.textContent?.trim()) || "Confirm"
    const destructive = submitter?.classList.contains("btn-danger") || form?.dataset.confirmDanger === "true"
    const dialog = document.createElement("dialog")
    dialog.className = "confirmation-modal"
    dialog.setAttribute("aria-labelledby", "confirmation-modal-title")
    dialog.setAttribute("aria-describedby", "confirmation-modal-message")

    const icon = document.createElement("div")
    icon.className = "confirmation-modal-icon"
    icon.textContent = destructive ? "!" : "?"
    icon.setAttribute("aria-hidden", "true")
    const title = document.createElement("h2")
    title.id = "confirmation-modal-title"
    title.textContent = "Confirm action"
    const description = document.createElement("p")
    description.id = "confirmation-modal-message"
    description.textContent = message
    const actions = document.createElement("div")
    actions.className = "confirmation-modal-actions"
    const cancel = document.createElement("button")
    cancel.type = "button"
    cancel.className = "btn-secondary"
    cancel.textContent = "Cancel"
    cancel.autofocus = true
    const confirm = document.createElement("button")
    confirm.type = "button"
    confirm.className = destructive ? "btn-danger" : "btn-primary"
    confirm.textContent = action
    actions.append(cancel, confirm)
    dialog.append(icon, title, description, actions)
    if (destructive) dialog.classList.add("confirmation-modal-danger")

    let finished = false
    const finish = (confirmed) => {
      if (finished) return
      finished = true
      document.removeEventListener("turbo:before-cache", cancelPending)
      document.removeEventListener("turbo:before-visit", cancelPending)
      dialog.close()
      dialog.remove()
      activeDialog = null
      if (previousFocus?.isConnected) previousFocus.focus()
      resolve(confirmed)
    }
    const cancelPending = () => finish(false)
    cancel.addEventListener("click", cancelPending)
    confirm.addEventListener("click", () => finish(true))
    dialog.addEventListener("cancel", (event) => {
      event.preventDefault()
      finish(false)
    })
    dialog.addEventListener("close", cancelPending)
    dialog.addEventListener("click", (event) => {
      const bounds = dialog.getBoundingClientRect()
      if (event.target === dialog && (event.clientX < bounds.left || event.clientX > bounds.right ||
          event.clientY < bounds.top || event.clientY > bounds.bottom)) finish(false)
    })
    document.addEventListener("turbo:before-cache", cancelPending)
    document.addEventListener("turbo:before-visit", cancelPending)
    activeDialog = dialog
    document.body.append(dialog)
    dialog.showModal()
    cancel.focus()
  })
}
