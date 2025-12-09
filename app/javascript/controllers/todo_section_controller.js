import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["todoList", "todoForm"];

  showForm() {
    this.todoListTarget.classList.add("hidden");
    this.todoFormTarget.classList.remove("hidden");
  }

  showList() {
    this.todoFormTarget.classList.add("hidden");
    this.todoListTarget.classList.remove("hidden");
  }
}
