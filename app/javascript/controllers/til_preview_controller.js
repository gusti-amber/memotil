import { Controller } from "@hotwired/stimulus";
import { post } from "@rails/request.js";

export default class extends Controller {
  static targets = ["editor", "preview"];
  static values = { url: String };

  async showPreview(event) {
    if (!event.currentTarget.checked) return;

    const formData = new FormData();
    formData.append("body", this.editorTarget.value);
    const response = await post(this.urlValue, {
      body: formData,
      responseKind: "html",
    });

    if (!response.ok) return;

    this.previewTarget.innerHTML = await response.text;
  }
}
