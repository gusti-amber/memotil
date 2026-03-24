import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "results"];

  search(event) {
    const q = event.target.value.trim();
    if (q.length < 2) {
      this.hideDropdown();
      return;
    }
    this.fetchSuggestions(q);
  }

  async fetchSuggestions(q) {
    const params = new URLSearchParams({ q });
    const url = `/tags/autocomplete?${params.toString()}`;
    try {
      const response = await fetch(url, { credentials: "same-origin" });
      const data = await response.json();
      this.displayResults(data.tags || []);
    } catch (error) {
      console.error(error.message);
    }
  }

  displayResults(tags) {
    if (!tags.length) {
      this.hideDropdown();
      return;
    }
    this.resultsTarget.innerHTML = tags
      .map((tag) => {
        const name = this.escapeHtml(tag.name);
        return `<li class="px-2 py-1 text-sm">${name}</li>`;
      })
      .join("");

    this.resultsTarget.classList.remove("hidden");
  }

  hideDropdown() {
    this.resultsTarget.classList.add("hidden");
  }

  escapeHtml(text) {
    const div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
  }
}
