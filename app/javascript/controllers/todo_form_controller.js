import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container", "addButton", "template", "todoField"];
  static values = {
    maxCount: { type: Number, default: 3 },
    confirmMessage: { type: String, default: "この項目を削除しますか？" },
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
    // クリックされた削除ボタンを子要素に持つtodoFieldを取得
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

    // daisyUI v5対応: disabled状態の見た目を確実に適用
    if (isDisabled) {
      this.addButtonTarget.classList.add("btn-disabled");
      this.addButtonTarget.classList.add("opacity-50");
      this.addButtonTarget.classList.add("cursor-not-allowed");
    } else {
      this.addButtonTarget.classList.remove("btn-disabled");
      this.addButtonTarget.classList.remove("opacity-50");
      this.addButtonTarget.classList.remove("cursor-not-allowed");
    }
  }

  get canAdd() {
    return this.todoCount < this.maxCountValue;
  }

  get todoCount() {
    // 非表示のtodoはフィルタリングし、表示されているtodoの数をカウント
    return this.todoFieldTargets.filter((todo) => todo.style.display !== "none")
      .length;
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
    // ここで取得するtodoの数は非表示のtodoも含む
    const todoCount = this.containerTarget.children.length;

    // インデックスを置換
    template.querySelectorAll('input[name*="INDEX"]').forEach((input) => {
      input.name = input.name.replace(/INDEX/g, todoCount);
    });

    return template;
  }
}
