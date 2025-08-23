import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container", "addButton", "template", "todoField"];
  static values = { maxCount: { type: Number, default: 3 } };
  static classes = ["disabled"];

  connect() {
    this.updateButtonState();
  }

  add() {
    if (this.todoCount >= this.maxCountValue) return;

    const newTodoElement = this.createNewTodoFromTemplate();
    this.containerTarget.appendChild(newTodoElement);
    this.updateButtonState();
  }

  remove(event) {
    const todoField = event.target.closest(
      "[data-todo-form-target='todoField']"
    );
    const destroyField = todoField.querySelector('input[name*="[_destroy]"]');
    const todoId = todoField.querySelector('input[name*="[id]"]').value;

    if (confirm("このtodoを削除しますか？")) {
      if (todoId) {
        // 既存のtodoの場合、削除マーク
        destroyField.value = "1";
        todoField.style.display = "none";
      } else {
        // 新規追加のtodoの場合、直接削除
        todoField.remove();
      }
      this.updateButtonState();
    }
  }

  updateButtonState() {
    const isDisabled = this.todoCount >= this.maxCountValue;

    this.addButtonTarget.disabled = isDisabled;
    if (isDisabled) {
      this.addButtonTarget.classList.add(this.disabledClass);
    } else {
      this.addButtonTarget.classList.remove(this.disabledClass);
    }
  }

  get todoCount() {
    return this.todoFieldTargets.filter((todo) => {
      const destroyField = todo.querySelector('input[name*="[_destroy]"]');
      const isDestroyed = destroyField && destroyField.value === "1";
      const isHidden = todo.style.display === "none";
      return !isDestroyed && !isHidden;
    }).length;
  }

  createNewTodoFromTemplate() {
    const todoCount = this.containerTarget.children.length;
    const template = this.templateTarget.content.cloneNode(true);

    // インデックスを置換
    template.querySelectorAll('input[name*="INDEX"]').forEach((input) => {
      input.name = input.name.replace(/INDEX/g, todoCount);
    });

    return template;
  }
}
