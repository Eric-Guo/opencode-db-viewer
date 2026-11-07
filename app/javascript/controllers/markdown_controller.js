import { Controller } from "@hotwired/stimulus"
import { marked } from "marked"
import DOMPurify from "dompurify"

export default class extends Controller {
  connect() {
    const source = this.element.textContent
    this.element.innerHTML = DOMPurify.sanitize(marked.parse(source, { async: false, gfm: true }), { USE_PROFILES: { html: true } })
    this.element.querySelectorAll("a").forEach(link => {
      link.setAttribute("rel", "noopener noreferrer")
    })
  }
}
