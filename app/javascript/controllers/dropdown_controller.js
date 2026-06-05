import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle(event) {
    event.stopPropagation()
    const menu = this.menuTarget
    if (menu.style.display === "none" || menu.style.display === "") {
      menu.style.display = "block"
    } else {
      menu.style.display = "none"
    }
  }

  hide(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.style.display = "none"
    }
  }
}