import { chromium } from 'playwright'
import assert from 'node:assert/strict'
const baseURL = process.env.PORTAL_BASE_URL || 'http://127.0.0.1:3100'
assert.ok(['localhost', '127.0.0.1'].includes(new URL(baseURL).hostname), 'Run loading regression checks locally')
const browser = await chromium.launch({ ...(process.env.CHROME_PATH ? { executablePath: process.env.CHROME_PATH } : {}), headless: true })
const page = await browser.newPage({ viewport: { width: 1440, height: 1000 } })
page.setDefaultTimeout(10000)
const errors = []; page.on('pageerror', error => errors.push(error.message))
const wait = milliseconds => new Promise(resolve => setTimeout(resolve, milliseconds))
try {
  await page.goto(baseURL + '/session/new')
  await page.route('**/forgot-password', async route => { await wait(900); await route.continue() })
  await page.getByRole('link', { name: 'Forgot password?' }).click()
  await page.locator('.portal-loading-auth').waitFor()
  await page.waitForURL(/forgot-password$/)
  await page.locator('[data-portal-loading]').waitFor({ state: 'detached' })
  await page.unroute('**/forgot-password')
  await page.goto(baseURL + '/session/new')
  await page.getByLabel('Username or email').fill(process.env.PORTAL_SUBMITTER_EMAIL || 'submitter@sapphire.pk')
  await page.getByLabel('Password', { exact: true }).fill(process.env.PORTAL_PASSWORD || 'ChangeMe!12345')
  await page.route('**/session', async route => { await wait(900); await route.continue() })
  await page.getByRole('button', { name: 'Sign in as Developer' }).click()
  await page.locator('[data-portal-loading="form"]').waitFor()
  assert.equal(await page.locator('[data-portal-loading="skeleton"]').count(), 0)
  await page.waitForURL(/\/developer(?:\/|$)/)
  await page.locator('[data-portal-loading]').waitFor({ state: 'detached' })
  await page.unroute('**/session')
  await page.evaluate(() => document.documentElement.dataset.turboPrefetch = 'false')

  await page.route('**/developer/development_reports', async route => { await wait(900); await route.continue() })
  await page.evaluate(() => window.Turbo.visit('/developer/development_reports'))
  const skeleton = page.locator('[data-portal-loading="skeleton"]')
  await skeleton.waitFor()
  assert.equal(await page.locator('main').getAttribute('aria-busy'), 'true')
  await page.screenshot({ path: 'tmp/skeleton-desktop.png' })
  await page.waitForURL(/development_reports$/)
  await skeleton.waitFor({ state: 'detached' })
  assert.equal(await page.locator('main').getAttribute('aria-busy'), null)
  await page.unroute('**/developer/development_reports')

  await page.route('**/developer/development_reports?**', async route => { await wait(900); await route.continue() })
  await page.locator('.datatable-selector').selectOption('25')
  await page.locator('.portal-loading-table').waitFor()
  await page.waitForURL(/per_page=25/)
  await skeleton.waitFor({ state: 'detached' })
  await page.unroute('**/developer/development_reports?**')

  await page.setViewportSize({ width: 390, height: 844 })
  await page.emulateMedia({ reducedMotion: 'reduce' })
  await page.route('**/developer/reviews', async route => { await wait(900); await route.continue() })
  await page.evaluate(() => window.Turbo.visit('/developer/reviews'))
  await skeleton.waitFor()
  assert.equal(await page.locator('.skeleton-block').first().evaluate(element => getComputedStyle(element).animationName), 'none')
  assert.ok(await skeleton.evaluate(element => element.getBoundingClientRect().right <= innerWidth))
  await page.screenshot({ path: 'tmp/skeleton-mobile.png' })
  await page.waitForURL(/reviews$/)
  await skeleton.waitFor({ state: 'detached' })
  await page.unroute('**/developer/reviews')

  await page.route('**/loading-test-frame', async route => {
    await wait(900)
    await route.fulfill({ contentType: 'text/html', body: '<turbo-frame id="loading-test-frame">Frame loaded</turbo-frame>' })
  })
  await page.evaluate(() => {
    const frame = document.createElement('turbo-frame'); frame.id = 'loading-test-frame'
    frame.style.height = '300px'; frame.style.display = 'block'; frame.src = '/loading-test-frame'
    document.querySelector('main').prepend(frame)
  })
  await skeleton.waitFor()
  await page.getByText('Frame loaded', { exact: true }).waitFor()
  await skeleton.waitFor({ state: 'detached' })
  assert.equal(await page.locator('#loading-test-frame').getAttribute('aria-busy'), null)

  // A canceled confirmation never starts a request or a loading indicator.
  await page.evaluate(() => {
    const form = document.createElement('form'); form.method = 'post'; form.action = '/session'
    form.dataset.turboConfirm = 'Confirm loading regression?'
    form.innerHTML = '<button type="submit">Check confirmation</button>'; document.querySelector('main').prepend(form)
  })
  await page.getByRole('button', { name: 'Check confirmation' }).click()
  await page.getByRole('dialog').getByRole('button', { name: 'Cancel' }).click()
  assert.equal(await page.locator('[data-portal-loading]').count(), 0)

  // Fast requests do not flash a skeleton; cleanup also runs before Turbo caching.
  await page.evaluate(() => {
    document.dispatchEvent(new CustomEvent('turbo:visit'))
    document.dispatchEvent(new CustomEvent('turbo:load'))
  })
  await wait(300)
  assert.equal(await page.locator('[data-portal-loading]').count(), 0)
  await page.evaluate(() => document.dispatchEvent(new CustomEvent('turbo:visit')))
  await skeleton.waitFor()
  await page.evaluate(() => document.dispatchEvent(new CustomEvent('turbo:fetch-request-error')))
  assert.equal(await page.locator('[data-portal-loading]').count(), 0)
  assert.equal(await page.locator('main').getAttribute('aria-busy'), null)
  await page.evaluate(() => document.dispatchEvent(new CustomEvent('turbo:visit')))
  await skeleton.waitFor()
  await page.evaluate(() => document.dispatchEvent(new Event('turbo:before-cache')))
  assert.equal(await page.locator('[data-portal-loading]').count(), 0)
  await page.goBack()
  await page.waitForTimeout(300)
  assert.equal(await page.locator('[data-portal-loading]').count(), 0)
  assert.deepEqual(errors, [])
  console.log('Passed: slow navigation, table filtering, login feedback, frames, canceled confirmation, quick requests, error/cache cleanup, reduced motion, responsive loading and no JS errors')
} finally { await browser.close() }
