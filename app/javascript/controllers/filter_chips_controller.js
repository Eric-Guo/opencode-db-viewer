import { Controller } from "@hotwired/stimulus"
import { Chip } from "@coreui/coreui-pro"

export default class extends Controller {
  static targets = ["chip"]

  connect() {
    this.chips = this.chipTargets.map(chip => Chip.getOrCreateInstance(chip))
  }

  remove(event) {
    event.preventDefault()
    window.location.assign(event.currentTarget.dataset.removeUrl)
  }

  disconnect() {
    this.chips.forEach(chip => chip.dispose())
  }
}
