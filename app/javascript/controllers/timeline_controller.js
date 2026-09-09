import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["entry", "filter", "search", "empty", "count"]

  connect() {
    this.category = "conversation"
    this.apply()
  }

  filter(event) {
    this.category = event.currentTarget.dataset.category
    this.apply()
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
