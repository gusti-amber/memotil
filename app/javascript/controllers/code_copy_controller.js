import { Controller } from "@hotwired/stimulus";

const FEEDBACK_MS = 1200;

export default class extends Controller {
  static targets = ["source", "button"];

  #defaultButtonLabel = "";
  #feedbackTimer = 0;

  connect() {
    this.#defaultButtonLabel = this.buttonTarget.textContent;
  }

  disconnect() {
    clearTimeout(this.#feedbackTimer);
    this.#feedbackTimer = 0;
  }

  async copy() {
    if (!navigator.clipboard) return;

    try {
      await navigator.clipboard.writeText(this.sourceTarget.value);
      this.#showTemporaryLabel("コピー済み");
    } catch (_error) {
      this.#showTemporaryLabel("失敗");
    }
  }

  #showTemporaryLabel(label) {
    clearTimeout(this.#feedbackTimer);
    this.buttonTarget.textContent = label;

    this.#feedbackTimer = window.setTimeout(() => {
      this.buttonTarget.textContent = this.#defaultButtonLabel;
      this.#feedbackTimer = 0;
    }, FEEDBACK_MS);
  }
}
