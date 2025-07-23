import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["checkbox"];

  toggle(event) {
    const form = event.target.closest("form");
    if (form) {
      form.requestSubmit();
    }
  }
}
