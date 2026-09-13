import { Controller } from "@hotwired/stimulus"
import { Autocomplete, SearchButton } from "@coreui/coreui-pro"

export default class extends Controller {
  static targets = ["button", "modal", "form", "autocomplete", "status"]
  static values = { url: String, empty: String, error: String, hint: String }

  connect() {
    this.button = SearchButton.getOrCreateInstance(this.buttonTarget)
    const placeholder = this.autocompleteTarget.querySelector("input").placeholder
    this.autocompleteTarget.replaceChildren()
    this.autocomplete = new Autocomplete(this.autocompleteTarget, {
      id: "project-search-input",
      name: "q",
      placeholder,
      options: [],
      search: "external",
      clearSearchOnSelect: false,
      searchNoResultsLabel: this.emptyValue,
      optionsMaxHeight: 280
    })
    this.input = this.autocompleteTarget.querySelector("input")
    this.input.setAttribute("aria-describedby", "project-search-hint")
    this.listeners = new AbortController()
    // Selecting an option moves focus into the field; suppress the browser's
    // implicit form submission for that same Enter key.
    this.autocompleteTarget.addEventListener("keydown", (event) => {
      if (event.key === "Enter" && event.target.matches('[role="option"]')) event.preventDefault()
    }, { capture: true, signal: this.listeners.signal })
    // CoreUI handles Enter on an option; Enter in the field submits the search.
    this.input.addEventListener("keydown", (event) => {
      if (event.key !== "Enter" || event.isComposing) return
      event.preventDefault()
      event.stopImmediatePropagation()
      this.formTarget.requestSubmit()
    }, { capture: true, signal: this.listeners.signal })
  }

  shown() {
    this.input.focus()
  }

  hidden() {
    clearTimeout(this.timeout)
    this.request?.abort()
    this.autocomplete.hide()
    this.buttonTarget.focus()
  }

  search() {
    this.selection = null
    this.request?.abort()
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.load(), 200)
  }

  async load() {
    this.request?.abort()
    const request = new AbortController()
    this.request = request
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("q", this.input.value.trim())
    this.autocompleteTarget.setAttribute("aria-busy", "true")
    try {
      const response = await fetch(url, { signal: request.signal, headers: { Accept: "application/json" } })
      if (!response.ok) throw new Error(`Project search: ${response.status}`)
      const options = await response.json()
      if (request.signal.aborted) return
      this.autocomplete.update({ options })
      this.statusTarget.textContent = options.length ? this.hintValue : this.emptyValue
      this.autocomplete.show()
    } catch (error) {
      if (error.name === "AbortError") return
      this.autocomplete.update({ options: [] })
      this.statusTarget.textContent = this.errorValue
    } finally {
      if (!request.signal.aborted) this.autocompleteTarget.removeAttribute("aria-busy")
    }
  }

  selected(event) {
    this.selection = typeof event.value === "object" ? event.value : null
    if (!this.selection) return
    clearTimeout(this.timeout)
    this.request?.abort()
    this.autocompleteTarget.removeAttribute("aria-busy")
  }

  submit(event) {
    if (!this.selection || this.input.value !== this.selection.label) return
    event.preventDefault()
    window.location.assign(this.selection.url)
  }

  disconnect() {
    clearTimeout(this.timeout)
    this.request?.abort()
    this.listeners.abort()
    this.autocomplete.dispose()
    this.button.dispose()
  }
}
