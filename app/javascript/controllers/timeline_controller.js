import { Controller } from "@hotwired/stimulus"
import { Chip, ChipSet } from "@coreui/coreui-pro"

export default class extends Controller {
  static targets = ["entry", "filter", "filters", "search", "empty", "count"]

  connect() {
    this.category = "conversation"
    this.chips = ChipSet.getOrCreateInstance(this.filtersTarget, { filter: true, selectionMode: "single" })
    this.apply()
  }

  filter(event) {
    if (!event.selected.length) {
      this.chips.selectChip(this.filterTargets.find(button => button.dataset.category === this.category))
      return
    }
    this.category = event.selected[0]
    this.apply()
  }

  reset() {
    this.searchTarget.value = ""
    this.chips.selectChip(this.filterTargets.find(button => button.dataset.category === "conversation"))
    this.apply()
  }

  disconnect() {
    this.filterTargets.forEach(button => Chip.getInstance(button)?.dispose())
    this.chips.dispose()
  }

  apply() {
    const query = this.searchTarget.value.trim().toLocaleLowerCase()
    let visible = 0
    this.entryTargets.forEach(entry => {
      const matches = this.category === "all" || entry.dataset.categories.split(" ").includes(this.category)
      entry.hidden = !matches || !entry.textContent.toLocaleLowerCase().includes(query)
      if (!entry.hidden) visible += 1
    })
    this.filterTargets.forEach(button => {
      const selected = button.dataset.category === this.category
      button.classList.toggle("active", selected)
      button.setAttribute("aria-pressed", String(selected))
    })
    this.countTarget.textContent = visible
    this.emptyTarget.hidden = visible !== 0
  }
}
