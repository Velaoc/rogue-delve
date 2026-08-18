import { Controller } from "@hotwired/stimulus"

// Turn-based movement: arrow keys / WASD submit the move form so Turbo
// handles the POST and redirect. Buttons use the same form.
export default class extends Controller {
  static targets = ["dx", "dy", "form"]

  connect() {
    window.addEventListener("keydown", this.onKey)
  }

  disconnect() {
    window.removeEventListener("keydown", this.onKey)
  }

  onKey = (event) => {
    const moves = {
      ArrowUp: [0, -1], ArrowDown: [0, 1], ArrowLeft: [-1, 0], ArrowRight: [1, 0],
      w: [0, -1], s: [0, 1], a: [-1, 0], d: [1, 0],
      W: [0, -1], S: [0, 1], A: [-1, 0], D: [1, 0]
    }
    const move = moves[event.key]
    if (!move) return

    event.preventDefault()
    if (this.element.dataset.status !== "active") return

    this.dxTarget.value = move[0]
    this.dyTarget.value = move[1]
    this.formTarget.requestSubmit()
  }

  setDirection(event) {
    const move = JSON.parse(event.currentTarget.dataset.move)
    this.dxTarget.value = move[0]
    this.dyTarget.value = move[1]
    this.formTarget.requestSubmit()
  }
}
