import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "toggle", "layout", "backdrop", "tab", "section"]

  toggle() {
    if (!this.panelTarget.hidden) return this.close()
    this.panelTarget.hidden = false
    this.backdropTarget.hidden = false
    this.layoutTarget.classList.add("inspector-open")
    this.toggleTarget.setAttribute("aria-expanded", "true")
    this.panelTarget.focus()
  }

  close() {
    if (this.panelTarget.hidden) return
    this.panelTarget.hidden = true
    this.backdropTarget.hidden = true
    this.layoutTarget.classList.remove("inspector-open")
    this.toggleTarget.setAttribute("aria-expanded", "false")
    this.toggleTarget.focus()
  }

  select(event) {
    const panel = event.currentTarget.dataset.panel
    this.tabTargets.forEach(tab => {
      const selected = tab.dataset.panel === panel
      tab.classList.toggle("active", selected)
      tab.setAttribute("aria-pressed", String(selected))
    })
    this.sectionTargets.forEach(section => { section.hidden = section.id !== `inspector-${panel}` })
  }

  trap(event) {
    if (this.panelTarget.hidden || !window.matchMedia("(max-width: 1199px)").matches) return
    const items = [...this.panelTarget.querySelectorAll("button, a, summary, input, [tabindex='0']")].filter(item => item.getClientRects().length)
    const first = items[0]
    const last = items[items.length - 1]
    if (event.shiftKey && (document.activeElement === first || document.activeElement === this.panelTarget)) {
      event.preventDefault()
      last?.focus()
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault()
      first?.focus()
    }
  }
}
