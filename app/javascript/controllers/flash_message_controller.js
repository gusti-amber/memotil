import { Controller } from "@hotwired/stimulus";

const AUTO_HIDE_MS = 6000;
const FADE_MS = 800;

export default class extends Controller {
  #autoHideTimer = 0;
  #removeTimer = 0;

  connect() {
    this.#autoHideTimer = window.setTimeout(
      () => this.#fadeOutAndRemove(),
      AUTO_HIDE_MS,
    );
  }

  disconnect() {
    clearTimeout(this.#autoHideTimer);
    clearTimeout(this.#removeTimer);
  }

  dismiss(event) {
    event.preventDefault();
    clearTimeout(this.#autoHideTimer);
    this.#fadeOutAndRemove();
  }

  #fadeOutAndRemove() {
    const el = this.element;
    el.classList.add("opacity-0", "pointer-events-none");
    this.#removeTimer = window.setTimeout(() => {
      if (el.isConnected) el.remove();
    }, FADE_MS);
  }
}
