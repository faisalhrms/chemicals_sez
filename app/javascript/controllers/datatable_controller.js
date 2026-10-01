import { Controller } from "@hotwired/stimulus"
import { DataTable } from "simple-datatables"

export default class extends Controller {
  static targets = ["table"]

  connect() {
    if (this.instance || this.toolbar) return
    this.table = this.tableTarget
    this.beforeCache = () => this.teardown()
    document.addEventListener("turbo:before-cache", this.beforeCache)
    this.rows = Array.from(this.table.tBodies[0].rows)
    this.emptyRow = this.rows.find(row => row.cells.length === 1 && row.cells[0].colSpan > 1)
    // DataTable renders rows afresh. Keep live form elements intact in editing tables.
    if (this.table.querySelector("input, select, textarea, form")) {
      this.setupEditorSearch()
      return
    }
    const columns = Array.from(this.table.tHead.rows[0].cells).flatMap((cell, index) => {
      if (/^(actions?|attachment|minutes)$/i.test(cell.textContent.trim())) {
        return [{ select: index, sortable: false, searchable: false }]
      }
      if (/date|updated|approved|reviewed/i.test(cell.textContent)) {
        return [{ select: index, type: "date", format: cell.textContent.includes("Reviewed") ? "DD-MM-YYYY HH:mm" : "DD-MM-YYYY" }]
      }
      return []
    })
    const emptyText = this.emptyRow?.textContent.trim() || "No records available."
    this.emptyRow?.remove()
    this.instance = new DataTable(this.table, {
      searchable: true, searchQuerySeparator: "", sortable: true, perPage: 10, perPageSelect: [10, 25, 50, 100],
      fixedColumns: false, columns,
      labels: { placeholder: "Search records…", searchTitle: "Search table", perPage: "rows per page",
        noRows: emptyText, noResults: "No matching records found.",
        info: "Showing {start}–{end} of {rows} records" }
    })
    this.instance.wrapperDOM.querySelector(".datatable-input")?.setAttribute("aria-label", "Search records")
  }

  setupEditorSearch() {
    this.toolbar = document.createElement("div")
    this.toolbar.className = "datatable-top editor-table-search"
    this.search = document.createElement("input")
    this.search.type = "search"
    this.search.className = "datatable-input"
    this.search.placeholder = "Search records…"
    this.search.setAttribute("aria-label", "Search records")
    this.count = document.createElement("span")
    this.count.className = "datatable-info"
    this.count.setAttribute("role", "status")
    this.toolbar.append(this.count, this.search)
    this.table.before(this.toolbar)
    this.filter = () => {
      const query = this.search.value.toLowerCase().trim()
      let visible = 0
      this.rows.forEach(row => {
        const values = Array.from(row.querySelectorAll("input, select, textarea")).map(input => input.value).join(" ")
        row.hidden = !`${row.textContent} ${values}`.toLowerCase().includes(query)
        if (!row.hidden) visible++
      })
      this.count.textContent = `${visible} of ${this.rows.length} records`
      this.emptyMessage.hidden = visible > 0
    }
    this.emptyMessage = document.createElement("p")
    this.emptyMessage.className = "datatable-empty"
    this.emptyMessage.textContent = "No matching records found."
    this.table.after(this.emptyMessage)
    this.search.addEventListener("input", this.filter)
    // Reveal filtered fields before browser validation tries to focus them.
    this.revealInvalid = () => { this.search.value = ""; this.filter() }
    this.table.addEventListener("invalid", this.revealInvalid, true)
    this.filter()
  }

  disconnect() {
    this.teardown()
    document.removeEventListener("turbo:before-cache", this.beforeCache)
  }

  teardown() {
    if (this.instance) {
      this.instance.destroy()
      this.instance = null
      this.table = this.tableTarget
      if (this.emptyRow) this.table.tBodies[0].replaceChildren(this.emptyRow)
    }
    if (this.toolbar) {
      this.rows.forEach(row => { row.hidden = false })
      this.table.removeEventListener("invalid", this.revealInvalid, true)
      this.toolbar.remove()
      this.emptyMessage.remove()
      this.toolbar = null
    }
  }
}
