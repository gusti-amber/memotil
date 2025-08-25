import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container", "addButton", "template", "todoField"];
  static values = {
    maxCount: { type: Number, default: 3 },
    confirmMessage: { type: String, default: "このtodoを削除しますか？" },
  };

  connect() {
    this.updateButtonState();
  }

  add() {
    if (this.canAdd) {
      this.containerTarget.appendChild(this.createNewTodo());
      this.updateButtonState();
    }
  }

  remove(event) {
    const todoField = event.target.closest(
      "[data-todo-form-target='todoField']"
    );

    if (confirm(this.confirmMessageValue)) {
      this.removeTodo(todoField);
      this.updateButtonState();
    }
  }

  updateButtonState() {
    const isDisabled = !this.canAdd;
    this.addButtonTarget.disabled = isDisabled;
    this.addButtonTarget.classList.toggle("btn-disabled", isDisabled);
  }

  get canAdd() {
    return this.todoCount < this.maxCountValue;
  }

  get todoCount() {
    return this.todoFieldTargets.filter((todo) => this.isValidTodo(todo))
      .length;
  }

  isValidTodo(todo) {
    const destroyField = todo.querySelector('input[name*="[_destroy]"]');
    const isDestroyed = destroyField?.value === "1";
    const isHidden = todo.style.display === "none";
    return !isDestroyed && !isHidden;
  }

  removeTodo(todoField) {
    // input要素のname属性に[id]が含まれている場合のみ、todoField要素のidを取得
    const todoId = todoField.querySelector('input[name*="[id]"]')?.value;

    if (todoId) {
      // 既存のtodo: 削除マークを設定して非表示
      todoField.querySelector('input[name*="[_destroy]"]').value = "1";
      todoField.style.display = "none";
    } else {
      // 新規todo: 直接削除
      todoField.remove();
    }
  }

  createNewTodo() {
    const template = this.templateTarget.content.cloneNode(true);
    const todoCount = this.containerTarget.children.length;

    // インデックスを置換
    template.querySelectorAll('input[name*="INDEX"]').forEach((input) => {
      input.name = input.name.replace(/INDEX/g, todoCount);
    });

    return template;
  }
}
