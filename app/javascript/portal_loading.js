const pending = new Map()
const delay = 200
const mainRegion = () => document.querySelector('main, .auth-form-panel, body > .page-shell')
let navigationRegion = null
let clickedRegion = null

function markBusy(region) {
  // Turbo owns aria-busy on forms and frames.
  if (region.matches("form, turbo-frame")) return () => {}
  const previous = region.getAttribute('aria-busy')
  region.setAttribute('aria-busy', 'true')
  return () => previous === null ? region.removeAttribute('aria-busy') : region.setAttribute('aria-busy', previous)
}

function skeleton(region) {
  const overlay = document.createElement('div')
  overlay.className = 'portal-loading-overlay'
  overlay.dataset.portalLoading = 'skeleton'
  const status = document.createElement('p')
  status.className = 'portal-loading-status'
  status.setAttribute('role', 'status')
  status.textContent = 'Loading content…'
  const shapes = document.createElement('div')
  shapes.className = 'portal-skeleton'
  shapes.setAttribute('aria-hidden', 'true')
  const block = (className, parent = shapes) => {
    const element = document.createElement('span')
    element.className = `skeleton-block ${className}`
    parent.append(element)
  }
  block('skeleton-title')
  block('skeleton-subtitle')
  const cards = document.createElement('div')
  cards.className = 'skeleton-cards'
  for (let index = 0; index < 3; index++) block('skeleton-card', cards)
  shapes.append(cards)
  const table = document.createElement('div')
  table.className = 'skeleton-table'
  block('skeleton-toolbar', table)
  for (let index = 0; index < 5; index++) block('skeleton-row', table)
  shapes.append(table)
  if (region.matches('.table-wrap, turbo-frame')) overlay.classList.add('portal-loading-table')
  if (region.matches('.auth-form-panel') || !document.querySelector('main')) overlay.classList.add('portal-loading-auth')
  overlay.append(status, shapes)
  document.body.append(overlay)
  const position = () => {
    const bounds = region.getBoundingClientRect()
    const top = Math.max(0, bounds.top)
    const left = Math.max(0, bounds.left)
    overlay.style.top = `${top}px`
    overlay.style.left = `${left}px`
    overlay.style.width = `${Math.max(0, Math.min(bounds.right, innerWidth) - left)}px`
    overlay.style.height = `${Math.max(0, Math.min(bounds.bottom, innerHeight) - top)}px`
  }
  position()
  window.addEventListener('resize', position)
  window.addEventListener('scroll', position, true)
  return () => {
    overlay.remove()
    window.removeEventListener('resize', position)
    window.removeEventListener('scroll', position, true)
  }
}

function begin(region, kind = 'skeleton', submitter = null) {
  if (!region) return
  end(region)
  const restoreBusy = markBusy(region)
  const state = { restoreBusy, remove: () => {} }
  state.timer = setTimeout(() => {
    if (!region.isConnected) return end(region)
    if (kind === 'skeleton') {
      state.remove = skeleton(region)
    } else {
      const status = document.createElement('span')
      status.className = 'portal-form-loading'
      status.dataset.portalLoading = 'form'
      status.setAttribute('role', 'status')
      status.textContent = 'Processing…'
      if (submitter) submitter.after(status)
      else region.append(status)
      state.remove = () => status.remove()
    }
  }, delay)
  pending.set(region, state)
}

function end(region) {
  const state = pending.get(region)
  if (!state) return
  clearTimeout(state.timer)
  state.remove()
  state.restoreBusy()
  pending.delete(region)
}

function reset() {
  for (const region of pending.keys()) end(region)
  navigationRegion = null
  clickedRegion = null
}

// Turbo emits this only for links it will handle, excluding downloads and external URLs.
document.addEventListener('turbo:click', event => {
  clickedRegion = event.target.closest('.table-wrap')
})
document.addEventListener('turbo:visit', () => {
  end(navigationRegion)
  navigationRegion = clickedRegion || mainRegion()
  clickedRegion = null
  begin(navigationRegion)
})
document.addEventListener('turbo:submit-start', event => {
  const form = event.target
  const submission = event.detail.formSubmission
  const method = submission.method.toLowerCase()
  const region = method === 'get' ? (form.closest('.table-wrap') || mainRegion() || form) : form
  form.portalLoadingRegion = region
  begin(region, method === 'get' ? 'skeleton' : 'form', submission.submitter)
})
document.addEventListener('turbo:submit-end', event => {
  const form = event.target
  // A successful GET may still be rendering its navigation response.
  if (form.portalLoadingRegion !== navigationRegion) end(form.portalLoadingRegion)
  delete form.portalLoadingRegion
})
document.addEventListener('turbo:before-fetch-request', event => {
  if (event.target.matches('turbo-frame')) begin(event.target)
})
for (const name of ['turbo:frame-load', 'turbo:frame-missing']) {
  document.addEventListener(name, event => end(event.target))
}
document.addEventListener('turbo:fetch-request-error', reset)
document.addEventListener('turbo:before-fetch-response', event => {
  const response = event.detail.fetchResponse
  if (!response.succeeded || !response.isHTML) reset()
})
document.addEventListener('turbo:render', () => {
  if (!document.documentElement.hasAttribute('data-turbo-preview')) reset()
})
document.addEventListener('turbo:load', reset)
document.addEventListener('turbo:before-cache', reset)
window.addEventListener('pageshow', reset)
