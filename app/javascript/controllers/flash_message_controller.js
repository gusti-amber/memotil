import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  dismiss(event) {
    event.preventDefault();
    const el = this.element;
    el.classList.add("opacity-0", "pointer-events-none");
    setTimeout(() => {
      if (el.isConnected) el.remove();
    }, 300);
  }
}
